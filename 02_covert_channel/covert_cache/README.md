```

Cache covert channel PoC: leak a word of secret information through cache timings.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Leaked word: dead (cycles: 1473)

```
