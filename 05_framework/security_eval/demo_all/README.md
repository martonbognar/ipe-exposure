This directory contains a CCS project with a minimal IPE program that demonstrates all three architectural attack primitives: arbitrary jump, arbitrary interrupt, and controlled call corruption. It can, thus, be used to validate that our mitigation framework successfully blocks the attacks.

## Attention points

* As this test attack program corrupts memory locations, it cannot be re-ran multiple times without re-uploading (i.e., stopping and starting a new CCS debug session).

* The `victim.c` file includes the `ipe_support.h` header. The CCS project configuration in this directory normally already ensures that `${CCS_PROJECT_DIR}/../../framework` is in the include path (`Build Options > MSP430 Compiler > Include Options`).

* `victim.c` also explicitly includes a multiplication, to make sure the compiler will insert a call to the `__mspabi_mpyi` helper function. Our `linker.py` script should intercept this relocation and transparently redirect the call to a secure `__ipe___mspabi_mpyi` variant.

* This project's CCS build configuration normally already ensures that the default linker is changed to our wrapper in `"${CCS_PROJECT_DIR}/../../framework/linker.py"` to transparently patch any relocations.

## Expected output

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
