#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

volatile uint16_t counter = 0;
uint16_t overflows[100] = {0};
uint16_t remainders[100] = {0};
bool first = true;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	counter = 0;

    CSCTL0_H = PMMPW_H;
    FRCTL0 = FRCTLPW | NWAITS_1;
    CSCTL1 = DCORSEL | DCOFSEL_4;
    CSCTL3 = DIVS_0 | DIVM_0;

    TA0CTL = TACLR;

    __bis_SR_register(GIE);
	
	// receiving on P1.2
    P1DIR &= ~BIT2;
    P1REN |= BIT2;
    P1OUT &= ~BIT2;

    // set up interrupts on low -> high
    P1IES &= ~BIT2;
    P1IE |= BIT2;

    // set up LEDs
    P1DIR |= BIT0;
    P1DIR |= BIT1;

    PM5CTL0 &= ~LOCKLPM5;

    P1OUT &= ~BIT0;
    P1OUT &= ~BIT1;

    while (counter < 100) {
        __no_operation();
    }

    for (unsigned i = 0; i < 100; ++i) {
        printf("%x%x\n", overflows[i], remainders[i]);
    }

	return 0;
}

#pragma vector=TIMER0_A1_VECTOR
__interrupt
void TIMER0_A1_ISR(void)
{
    TA0CTL &= ~TAIFG;
    overflows[counter] += 1;
}

#pragma vector=PORT1_VECTOR
__interrupt
void PORT1_ISR(void)
{
    TA0CTL = 0;
    uint16_t tarcopy = TA0R;
    // restart timer
    TA0CTL = TACLR | TASSEL_2 | MC_2 | TAIE;
    P1IFG = 0;
    P1IV = 0;
    if (first) {
        first = false;
        return;
    }
    if (counter < 100) {
        remainders[counter++] = tarcopy;
    } else {
        TA0CTL = 0;
        // turn on LED
        P1OUT |= BIT0;
        P1IE &= ~BIT2;
    }
}
