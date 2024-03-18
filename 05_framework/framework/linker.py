#!/usr/bin/python3
import sys
import os
import re
import subprocess
from elftools.elf.elffile import ELFFile

# ld options that are not supported by compiler
ld_only_opts = [r'-m\w*.map',
                r'--heap_size=\d*',
                r'--stack_size=\d*',
                r'--cinit_hold_wdt=on',
                r'--priority',
                r'--reread_libs',
                r'--warn_sections',
                r'--xml_link_info=\w*_linkInfo.xml',
                r'--rom_model',
                r'-z'
               ]

def patch_relocs(fn):
    elf_relocations = []

    with open(fn, 'rb') as f:
        elf_file = ELFFile(f)

        for section in elf_file.iter_sections():
            if not re.match(r'.rel.ipe_(func|entry):\w+', section.name):
                continue
            print(f'.. processing section <{section.name}>')

            symtab = elf_file.get_section(section['sh_link'])
            for n in range(section.num_relocations()):
                rel = section.get_relocation(n)
                sym = symtab.get_symbol(rel['r_info_sym'])

                if re.match(r'(memset|__mspabi_\w+)', sym.name):
                    print(f'\tL__ intercepting relocation {sym.name}')
                    rel_offset = section['sh_offset'] + n * section['sh_entsize']
                    elf_relocations.append((rel_offset, sym.name))

    print(f".. applying relocation patches to '{fn}'")
    with open(fn, 'r+b') as f:
        elf_file = ELFFile(f)
        symtab = elf_file.get_section_by_name('.symtab')
        for (rel_offset, sym_name) in elf_relocations:
            ipe_sym_name = '__ipe_' + sym_name

            # get symbol table index of added symbol
            for sym_idx in range(symtab.num_symbols()):
                if symtab.get_symbol(sym_idx).name == ipe_sym_name:
                    break
            if (symtab.get_symbol(sym_idx).name != ipe_sym_name):
                print(f"\tL__ WARNING: '{ipe_sym_name:22}' not defined; skipping..")
                continue

            # overwrite symbol table index in targeted relocation
            # skip r_offset and patch r_info 3 bytes (litte endian; lower byte
            # stores relocation type)
            # https://wiki.osdev.org/ELF_Tutorial#Relocation_Sections
            print(f"\tL__ patching relocation  for symbol '{sym_name:22}'@{rel_offset} -> '{ipe_sym_name:27}'@{sym_idx}")
            f.seek(rel_offset+5)
            f.write(sym_idx.to_bytes(3, byteorder='little'))

def process_filename(filename):
    print(f'processing relocations in: {filename}')
    patch_relocs(filename)

def run_cmd(cmdline):
    cmdline = " ".join(cmdline)
    print(f'running: {cmdline}')
    c = subprocess.run(cmdline, shell=True, capture_output=True, text=True)
    print(c.stdout, end='')
    print(c.stderr, end='')
    return c.returncode

def main():
    # Expect the TI tool root directory to be passed from CCS
    if not 'CG_TOOL_ROOT' in os.environ:
        print('error: $CG_TOOL_ROOT not defined; was I called through the CCS IDE?')
        sys.exit(1)
    else:
        print(f'MSP430 tool root directory is: {os.environ["CG_TOOL_ROOT"]}')

    # Extract non-option arguments (filenames) and call our custom relocation patcher
    filenames = [arg for arg in sys.argv[1:] if arg.endswith('.obj') and not arg.startswith('-')]
    mpu_enabled = False
    for filename in filenames:
        if 'generated' in filename:
            mpu_enabled = True
        process_filename(filename)
    print(f'found mpu_enabled={mpu_enabled}')

    # Find all C/asm files in libipe (skip MPU files unless we detect
    # translator.py has been called to generate stubs)
    libipe = os.path.dirname(sys.argv[0]) + '/libipe'
    libipe_files = []
    for root, _, files in os.walk(libipe):
        for filename in files:
            if any(filename.endswith(ext) for ext in ['.s', '.asm', '.c']) \
                    and (not 'mpu' in filename or mpu_enabled):
                libipe_files.append(os.path.join(root, filename))

    # Compile libipe objects and add them to the linker cmdline
    cl430 = os.environ['CG_TOOL_ROOT'] + '/bin/cl430'
    linker_args = [cl430] + sys.argv[1:]
    compiler_args = [cl430] + sys.argv[1:sys.argv.index('-o')]
    compiler_args = [a for a in compiler_args if not any(re.match(r, a) for r in ld_only_opts)]
    for f in libipe_files:
        rv = run_cmd(compiler_args + ['-c', f]) 
        if rv != 0:
            print(f'fatal: compiler returned non-zero return value: {rv}')
            sys.exit(rv)
        # insert after the last obj file in the linker cmdline
        objfile = os.path.splitext(os.path.basename(f))[0] + '.obj'
        last_obj_idx = max(idx for idx, val in enumerate(linker_args) if val.endswith('.obj'))
        linker_args.insert(last_obj_idx + 1, objfile)

    # Finally link everything together with the default MSP430 linker
    sys.exit(run_cmd(linker_args))

if __name__ == '__main__':
    main()
