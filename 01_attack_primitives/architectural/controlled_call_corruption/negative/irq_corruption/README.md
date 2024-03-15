Implicit writes on the MSP430 architecture are not only performed by call instructions.
Interrupt handlers push the interrupted instruction's address and the status register to the stack.
We thoroughly examined the behavior of this mechanism, as it appears similar to the call instruction,
but we found that the access control was indeed correctly enforced, even when the interrupted code
and the ISR also resided in the IPE region.

First, run the program normally without a reset, observe the corruption of the key:

Expected output:
```
123 4567 89ab cdef aaaa bbbb cccc dddd
123 4567 f008 89aa aaaa bbbb cccc dddd
```

Then, relaunch the debug session, do a hard reset (to enable IPE), and observe the key no longer getting corrupted:

Expected output:

```
123 4567 89ab cdef aaaa bbbb cccc dddd
123 4567 89ab cdef aaaa bbbb cccc dddd
```
