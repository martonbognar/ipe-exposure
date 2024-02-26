#include <msp430.h> 

int _system_pre_init(void) {
    WDTCTL = WDTPW | WDTHOLD;

    // sending on P1.3
    P1DIR |= BIT3;
    P1OUT &= ~BIT3;
    PM5CTL0 &= ~LOCKLPM5;
    P1OUT |= BIT3;
    P1OUT &= ~BIT3;

    PMMCTL0 = PMMPW | PMMSWBOR;

    return 1;
}

int main(void)
{
    return 0;
}
