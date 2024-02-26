#include <msp430.h> 

int _system_pre_init(void) {
    WDTCTL = WDTPW | WDTHOLD;

    // sending on P1.2
    P1DIR |= BIT2;
    P1OUT &= ~BIT2;
    PM5CTL0 &= ~LOCKLPM5;
    P1OUT |= BIT2;
    P1OUT &= ~BIT2;

    PMMCTL0 = PMMPW | PMMSWBOR;

    return 1;
}

int main(void)
{
    return 0;
}
