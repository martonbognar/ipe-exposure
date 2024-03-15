```
#include <msp430.h> 

int _system_pre_init(void) {
WDTCTL = WDTPW | WDTHOLD;

/ sending on P7.6 (under GND on top right array)
P7DIR |= BIT6;
P7OUT &= ~BIT6;
PM5CTL0 &= ~LOCKLPM5;
P7OUT |= BIT6;
P7OUT &= ~BIT6;

PMMCTL0 = PMMPW | PMMSWBOR;

return 1;
}

int main(void)
{
return 0;
}

```
