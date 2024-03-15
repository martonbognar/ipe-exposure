```

MPU covert channel PoC: leak a word of secret information through MPU violations.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Leaked word: beef (cycles: 750)

```
