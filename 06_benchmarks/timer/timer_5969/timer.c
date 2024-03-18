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
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer
    counter = 0;

    puts("timer: listening for interrupts on P1.3 (make sure to hit resume for every subsequent print statement in the debugger)..");

    CSCTL0_H = PMMPW_H;
    FRCTL0 = FRCTLPW | NWAITS_1;
    CSCTL1 = DCORSEL | DCOFSEL_4;
    CSCTL3 = DIVS_0 | DIVM_0;

    TA0CTL = TACLR;

    __bis_SR_register(GIE);

    // receiving on P1.3
    P1DIR &= ~BIT3;
    P1REN |= BIT3;
    P1OUT &= ~BIT3;

    // set up interrupts on low -> high
    P1IES &= ~BIT3;
    P1IE |= BIT3;

    // set up LEDs
    P1DIR |= BIT0;

    PM5CTL0 &= ~LOCKLPM5;

    P1OUT &= ~BIT0;

    while (counter < 100) {
        __no_operation();
    }

    puts("printing measurements (copy-paste the line below into a CSV file):");
    for (unsigned i = 0; i < 100; ++i) {
        printf("%x%x,", overflows[i], remainders[i]);
    }

    puts("\nall done! exiting..");

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
        P1IE &= ~BIT3;
    }
}
