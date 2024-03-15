This program tests the inverse situation of the CALL exploit: an IPE function calling an unprotected function with SP pointing inside IPE.
The return address is not written to IPE, confirming the hypothetical cause of the CALL exploit.

First, run the program with no reset, observe how the key is corrupted:

```
Expected output:
123 4567 89ab cdef aaaa bbbb cccc dddd
484e 0 89ab cdef aaaa bbbb cccc dddd
```

Then, stop and relaunch the debug session, and perform a hard reset (to activate IPE)
before starting the program, and observe how the corruption is prevented:

```
Expected output:
123 4567 89ab cdef aaaa bbbb cccc dddd
123 4567 89ab cdef aaaa bbbb cccc dddd
```
