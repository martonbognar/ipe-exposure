# Security framework

This directory contains the source code for our software framework to improve the security of IPE projects.

## Installation

```shell
pip install -r requirements.txt --no-deps
```

## Running the translator

Use the `translator.py` script on your C source file that contains the IPE function and data definitions. This will generate assembly stubs and a partial C file in its output directory. Replace the IPE functions with the generated variants and include `generated_ipe_header.h` in your original source file, and add the generated assembly stubs to the list of compiled files. Include our linker script and the provided assembly files in `stubs/` in your project.

```
 ./translator.py --help
usage: translator.py [-h] -ccs CCS [-output OUTPUT] source_file

Source-to-source translator for IPE security

positional arguments:
  source_file

optional arguments:
  -h, --help      show this help message and exit
  -ccs CCS        Path to the CCS directory on your system (e.g., /home/user/ti/ccs1230/ccs).
  -output OUTPUT  Path to the output file directory (default: ./output/).
```

## Copyright notice

The files in `fake_libc_include` are copied from <https://github.com/eliben/pycparser>.



## TODO

* improve doc on how  to use the stubs in a new project
* doc support compile-time stubs