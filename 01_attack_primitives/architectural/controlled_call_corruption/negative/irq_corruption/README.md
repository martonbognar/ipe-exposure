```
#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

void attacker();


Implicit writes on the MSP430 architecture are not only performed by call instructions.
Interrupt handlers push the interrupted instruction's address and the status register to the stack.
We thoroughly examined the behavior of this mechanism, as it appears similar to the call instruction,
but we found that the access control was indeed correctly enforced, even when the interrupted code
and the ISR also resided in the IPE region.

```
