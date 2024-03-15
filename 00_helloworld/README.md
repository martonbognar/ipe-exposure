```

Helloworld to test IPE functionality.

How to run:
1. Load program, run until you see the output.
2. Hard reset, run program again (now with IPE enabled).

Expected output:
----------
Reading secret from main: 1234 (IPE disabled)
Reading secret from IPE : 1234
----------
Reading secret from main: 3fff (IPE enabled)
Reading secret from IPE : 1234
----------

Explanation:
0: IPE is not yet activated, key is visible.
1: IPE is activated in the default configuration, reading the key returns the default 3fff value.

```
