This directory contains a CCS project with a minimal IPE program that demonstrates all three architectural attack primitives: arbitrary jump, arbitrary interrupt, and controlled call corruption. It can, thus, be used to validate that our mitigation framework successfully blocks the attacks.

## Attention points

* As this test attack program corrupts memory locations, it cannot be re-ran multiple times without re-uploading (i.e., stopping and starting a new CCS debug session).

* When running with the MPU protection enabled: as the console detaches on resets, the values of buffer, public, expected_public need to be examined in the Memory Browser at the end of executions.

* The `victim.c` file includes the `ipe_support.h` header. The CCS project configuration in this directory normally already ensures that `${CCS_PROJECT_DIR}/../../framework` is in the include path (`Build Options > MSP430 Compiler > Include Options`).

* `victim.c` also explicitly includes a multiplication, to make sure the compiler will insert a call to the `__mspabi_mpyi` helper function. Our `linker.py` script should intercept this relocation and transparently redirect the call to a secure `__ipe___mspabi_mpyi` variant.

* This project's CCS build configuration normally already ensures that the default linker is changed to our wrapper in `"${CCS_PROJECT_DIR}/../../framework/linker.py"` to transparently patch any relocations.

## Expected output without MPU

```
Key directly: 3fff (IPE enabled)
Value of declassified: 7310

=== ROUND 0: attack disabled ===
1. Jump attack: jumps to the middle with fake key and corrupts the calculation
	L_ Value of declassified after attack: 7310 			[FAIL]
2. IRQ attack: steals original key and corrupts the calculation
	L_ Value of buffer: 0                    			[FAIL]
	L_ Value of declassified after attack: 7310 			[FAIL]
3. CALL attack: corrupts the key and, thus, the calculation
	L_ Value of declassified after attack: 7310 			[FAIL]

=== ROUND 1: attack enabled ===
1. Jump attack: jumps to the middle with fake key and corrupts the calculation
	L_ Value of declassified after attack: 6e4 			[OK]
2. IRQ attack: steals original key and corrupts the calculation
	L_ Value of buffer: 123                    			[OK]
	L_ Value of declassified after attack: 61c4 			[OK]
3. CALL attack: corrupts the key and, thus, the calculation
	L_ Value of declassified after attack: 5944 			[OK]

main: all done; exiting..
```

## Expected output with MPU

```
$ ./run.sh 
.. copying base 'demo_all' CCS project to 'demo_all_mitigated'
.. sanity-check CCS project configuration
	L_ searching for libipe    in file: demo_all_mitigated/.cproject [OK]
	L_ searching for linker.py in file: demo_all_mitigated/.cproject [OK]
.. running translator.py
.. fixing victim.c
.. generating diff summary
	L_ Only in demo_all: Debug
	L_ Only in demo_all_mitigated: generated_ipe_header.h
	L_ Only in demo_all_mitigated: generated_stubs.s
	L_ Only in demo_all_mitigated: generated_table.s
	L_ Files demo_all/.project and demo_all_mitigated/.project differ
	L_ Files demo_all/victim.c and demo_all_mitigated/victim.c differ
.. all done; ready to import 'demo_all_mitigated' as a new CCS project!
```
