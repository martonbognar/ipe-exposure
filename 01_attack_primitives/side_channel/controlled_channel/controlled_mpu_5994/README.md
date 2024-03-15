```

Controlled channel attack with the MPU: detect whether IPE tried to access a given memory region.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Violation detected: first run: false, second run: true

```
