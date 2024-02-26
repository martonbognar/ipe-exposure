#!/usr/bin/env python3

import argparse
import copy
import os
import sys

from pycparser import c_ast
from pycparserext import ext_c_parser
from pycparserext.ext_c_generator import GnuCGenerator

# required by parser library
sys.path.extend(['.', '..'])

# converts number into bitmap
def make_bitmap(registers_used):
    if registers_used == 0:
        return "00000000b"
    if registers_used == 1:
        return "00001000b"
    if registers_used == 2:
        return "00001100b"
    if registers_used == 3:
        return "00001110b"
    else:
        return "00001111b"

# throw an exception if function uses stack passing
def break_if_stack_passing(funcDefExt, reg_used):
    funcName = funcDefExt.type.declname
    return_type = funcDefExt.type.type
    if isinstance(return_type, c_ast.Struct):  # 1 argument register used as pointer to struct
        if reg_used > 3:
            raise NotImplementedError("Stack passing in " + funcName)
    else:
        if reg_used > 4:
            raise NotImplementedError("Stack passing in " + funcName)

# include declaration of function at top of translated file
def include_declaration(funcDecl, includeAst, suffix):
    decl_copy = copy.deepcopy(funcDecl)
    decl_copy.name += suffix
    decl_copy.type.type.declname += suffix
    # delete function attributes
    decl_copy.funcspec = []
    includeAst.ext.append(decl_copy)

# return the number of registers used as argument to a function
class ArgumentRegCounter(c_ast.NodeVisitor):
    def __init__(self):
        self.reg_used = 0

    # returns the number of registers used as argument for the provided types of arguments
    @staticmethod
    def nb_reg_used(argTypes):
        nb_reg = 0
        # data sizes in MSPCompilerGuide p82 (for restricted data model) (enums not supported)
        for argType in argTypes:
            if argType in ["long long", "signed long long", "unsigned long long", "double", "long double"]:  # 64 bit == 4 reg
                nb_reg += 4
            elif argType in ["long", "signed long", "unsigned long", "float"]:  # 32 bit == 2 reg
                nb_reg += 2
            elif argType in ["void"]:
                nb_reg += 0
            else:
                nb_reg += 1
        return nb_reg

    def visit_Decl(self, node):
        arg_type = node.type
        if isinstance(arg_type, c_ast.PtrDecl):
            self.reg_used += 2  # for restricted data model
        else:
            self.reg_used += self.nb_reg_used(arg_type.type.names)

# register all ocalls in IPE function + redirect ocall to new stub
class OcallCollector(c_ast.NodeVisitor):
    def __init__(self, ipe_functions, inline_functions):
        self.ipe_functions = ipe_functions
        self.inline_functions = inline_functions
        self.ocall_functions = {}
        self.ocall_detected = False

    def visit_FuncCall(self, node):
        funcName = node.name.name
        # works because function declaration must proceed function call
        if funcName not in self.ipe_functions and funcName not in self.inline_functions and "__" not in funcName:
            self.ocall_detected = True
            self.ocall_functions[funcName] = node
            # change ocalls not declaration, because unprotected --> unprotected calls should not go through stub
            node.name.name += "_stub"

# for all entry functions in IPE:
#   change name of function
#   add to entry function table
#   write a unprotected stub with old name
#   include declaration of stub at top of translated file
class IPECollector(c_ast.NodeVisitor):
    def __init__(self, generated_header, replacement_functions, table_file, stub_file):
        self.index = 0
        self.generated_header = generated_header
        self.replacement_functions = replacement_functions
        self.table_file = table_file
        self.stub_file = stub_file
        self.ipe_functions = {}
        self.inline_functions = {}

    def write_max_index(self):
        self.table_file.write(f"""
entryCount:
    .word {self.index}
""")

    # table to register address and number of registers used as argument for every entry function
    # table consulted at runtime by "ipe_entry" stub in ipe_stubs.s
    def entry_table_append(self, funcName, reg_used):
        self.table_file.write(f"""
    .global {funcName}
    .field {funcName},32
    .byte {make_bitmap(reg_used)}
""")

    # stub for all entry functions in IPE, stub:
    #   sets r7 to the index of the entry function in the entry function table (see write_table.py)
    # r7 used by "ipe_entry" stub in ipe_stubs.s
    def entry_stub_write(self, function_name):
        self.stub_file.write(f"""
    .global {function_name}
    .sect ".text"
{function_name}:
    push r7
    mov #{self.index}, r7
    calla #reset_into_ipe
    pop r7
    reta
""")
        self.index += 1

    def visit_FuncDef(self, node):
        function_name = node.decl.name
        # check attributes for IPE annotations (see ipe.support.h), if IPE function then register function name
        for attributes_group in node.decl.funcspec:
            if attributes_group == "inline":
                # if inlined function, we ignore it
                self.inline_functions[function_name] = node
                continue
            for attribute in attributes_group.exprlist.exprs:
                # attribute is a section attribute
                if isinstance(attribute, c_ast.FuncCall):
                    sectionName = attribute.args.exprs[0].value[1:-1]
                    if sectionName == ".ipe_entry":
                        self.ipe_functions[function_name] = node
                        internal_name = function_name + "_internal"
                        if (node.decl.type.args):
                            v = ArgumentRegCounter()
                            v.visit(node.decl.type.args)
                            break_if_stack_passing(node.decl.type, v.reg_used)
                        return_regs = ArgumentRegCounter.nb_reg_used(node.decl.type.type.type.names)
                        self.entry_table_append(internal_name, return_regs)
                        self.entry_stub_write(function_name)
                        include_declaration(node.decl, self.generated_header, "")
                        # change declaration name not ecalls, because this way ecall from other file possible
                        node.decl.type.type.declname = internal_name
                        # append function with new name to ext ast
                        self.replacement_functions.ext.append(node)
                    if sectionName == ".ipe_func":
                        self.ipe_functions[function_name] = node


# for all ocalls in IPE:
#   write a protected stub
#   include declaration of new stub at top of translated file
class OcallStubCreator(c_ast.NodeVisitor):
    def __init__(self, generated_header, stubFile, ocall_functions):
        self.stubFile = stubFile
        self.generated_header = generated_header
        self.ocall_functions = ocall_functions


    # stub for all ocalls in IPE, stub:
    #   sets r6 to number of registers used as arguments
    #   sets r7 to address of unprotected function
    # r6 and r7 used by "call_untrusted" stub in ipe_stubs.s
    def unprotected_stub_write(self, funcName, nb_reg_used):
        stubname = funcName + "_stub"
        self.stubFile.write(f"""
    .global {funcName}
    .global {stubname}
    .sect ".ipe_func"
{stubname}:
    push r6
    push r7
    mov #{make_bitmap(nb_reg_used)}, r6
    mova #{funcName}, r7
    calla #call_untrusted
    pop r7
    pop r6
    reta
""")

    def visit_Decl(self, node):
        arg_type = node.type
        if isinstance(arg_type, ext_c_parser.FuncDeclExt):
            funcName = node.type.type.declname
            if funcName in self.ocall_functions:
                if (node.type.args):
                    v = ArgumentRegCounter()
                    v.visit(node.type.args)
                    break_if_stack_passing(node.type, v.reg_used)
                    self.unprotected_stub_write(funcName, v.reg_used)
                else:
                    self.unprotected_stub_write(funcName, 0)
                include_declaration(node, self.generated_header, "_stub")

def base_name(filename):
    local_name = filename.split('/')[-1]
    return '.'.join(local_name.split('.')[:-1])

def preprocessed_name(filename):
    base = base_name(filename)
    return base + '.pp'


def ast_from_source(CCS_DIR, parser, filename):
    pp_file_name = preprocessed_name(filename)
    os.system(f'{CCS_DIR}/tools/compiler/ti-cgt-msp430_21.6.1.LTS/bin/cl430 -vmspx --data_model=restricted --use_hw_mpy=F5 --include_path={os.path.abspath(os.path.dirname(__file__))}/fake_libc_include --include_path={CCS_DIR}/ccs_base/msp430/include --include_path={os.path.abspath(os.path.dirname(__file__))} --include_path={CCS_DIR}/tools/compiler/ti-cgt-msp430_21.6.1.LTS/include --advice:power=all --advice:hw_config=all --define=__MSP430FR5969__ --define=_IPE_ENABLE --define=_MPU_ENABLE -g --printf_support=minimal --diag_warning=225 --diag_wrap=off --display_error_number --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --preproc_only {filename} --output_file={pp_file_name}')

    pp_file = open(pp_file_name, "r")
    src = pp_file.read()
    return parser.parse(src, filename=pp_file_name)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Source-to-source translator for IPE security")
    parser.add_argument('source_file')
    parser.add_argument('-ccs', required=True, help="Path to the CCS directory on your system (e.g., /home/user/ti/ccs1230/ccs).")
    parser.add_argument('-output', help="Path to the output file directory (default: ./output/).", default="output")
    args = parser.parse_args()

    try:
        os.mkdir(args.output)
    except FileExistsError as e:
        pass

    parser = ext_c_parser.GnuCParser()
    original_ast = ast_from_source(args.ccs, parser, args.source_file)

    pp_file_name = preprocessed_name(args.source_file)

    replacement_functions = parser.parse("", filename='<none>')
    generated_header = parser.parse("", filename='<none>')

    tableFile = open(os.path.join(args.output, "generated_table.s"), "w")
    tableFile.write("    .global entryFuncs\n")
    tableFile.write("    .global entryCount\n")
    tableFile.write("    .sect \".ipe_const\"\n")
    tableFile.write("entryFuncs:\n")

    stubFile = open(os.path.join(args.output, "generated_stubs.s"), "w")
    stubFile.write("    .global reset_into_ipe\n")
    stubFile.write("    .global call_untrusted\n\n")

    ipe_collector = IPECollector(generated_header, replacement_functions, tableFile, stubFile)
    ipe_collector.visit(original_ast)
    ipe_collector.write_max_index()

    ocall_collector = OcallCollector(ipe_collector.ipe_functions, ipe_collector.inline_functions)

    for ipe_fn in ipe_collector.ipe_functions.values():
        ocall_collector.ocall_detected = False
        ocall_collector.visit(ipe_fn)
        if ocall_collector.ocall_detected and ipe_fn not in replacement_functions.ext:
            replacement_functions.ext.append(ipe_fn)

    ocall_stub_creator = OcallStubCreator(generated_header, stubFile, ocall_collector.ocall_functions)
    ocall_stub_creator.visit(original_ast)

    # write translation result to new file
    with open(os.path.join(args.output, 'generated_ipe_header.h'), "w") as newFile:
        newFile.write(GnuCGenerator().visit(generated_header))

    newFile = open(os.path.join(args.output, base_name(args.source_file) + '.c'), "w")
    for line in GnuCGenerator().visit(replacement_functions).splitlines():
        if "asm" in line:
            newFile.write(line + ";\n")
        else:
            newFile.write(line + "\n")

    # clean up
    os.remove("./lextab.py")
    os.remove("./yacctab.py")
    os.remove(pp_file_name)
