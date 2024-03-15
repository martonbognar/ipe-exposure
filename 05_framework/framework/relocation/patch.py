#!/usr/bin/python3
import argparse
import re
import sys
import subprocess
from elftools.elf.elffile import ELFFile

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

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('filename')
    args = parser.parse_args()

    patch_relocs(args.filename)
