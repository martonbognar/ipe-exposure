```

AES key overwrite with call: overwriting the secret AES key to obtain decipherable outputs.

After launching the debug session, do a hard reset (to activate IPE), then run the code.

Expected output:
----------------
Trying to read secret directly:
Byte: 3fff
Byte: 3fff
Byte: 3fff
Byte: 3fff
Byte: 3fff
Byte: 3fff
Byte: 3fff
Byte: 3fff

Decoded values with known key:
Byte: de
Byte: ad
Byte: be
Byte: ef
Byte: ca
Byte: fe
Byte: ba
Byte: be
----------------

```
