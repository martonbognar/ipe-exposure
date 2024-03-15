```

CALL overwriting the IPE struct

How to run:
1. Load program, run until you see the output.
2. Hard reset, run program again (now with IPE enabled). The exploit will be run now.
3. Hard reset, run the program again. The effect of the exploit will be visible now.

Expected output:
----------------
Leak: 123 (0)
Leak: 3fff (1)
Leak: 123 (2)
----------------

Explanation:
0: IPE is not yet activated, key is visible.
1: IPE is activated in the default configuration, reading the key returns the default 3fff value.
2: After the exploit, the IPE struct is overwritten and the incorrect area of memory will be protected, making the key visible again.

```
