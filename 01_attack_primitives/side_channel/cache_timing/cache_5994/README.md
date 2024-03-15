```

Cache attack PoC: show a difference in timing of a memory access depending on victim activity.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Timing at low clock speed: 5, 5
Timing with cache delay:   6, 5

```
