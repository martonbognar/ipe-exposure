```

CALL leakage v1: inserting a universal read gadget to the end of the IPE region.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Reading key directly:
Key: 3fff
Key: 3fff
Key: 3fff
Key: 3fff
Key: 3fff
Leaked: 123
Leaked: 4567
Leaked: 89ab
Leaked: cdef
Leaked: aaaa
----------------

```
