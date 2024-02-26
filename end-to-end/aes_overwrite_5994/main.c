/**
 * AES key overwrite with call: overwriting the secret AES key to obtain decipherable outputs.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Trying to read secret directly:
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 * Byte: 3fff
 *
 * Decoded values with known key:
 * Byte: de
 * Byte: ad
 * Byte: be
 * Byte: ef
 * Byte: ca
 * Byte: fe
 * Byte: ba
 * Byte: be
 * ----------------
 */

#include <stdio.h>
#include <msp430.h>
#include <stdint.h>
#include <assert.h>

#pragma DATA_SECTION(IPE_encapsulatedCount, ".ipe_vars")
uint8_t IPE_encapsulatedCount;

#pragma DATA_SECTION(IPE_i, ".ipe_vars")
uint8_t IPE_i;

#pragma DATA_SECTION(IPE_encapsulatedKeys, ".ipe_const")
const uint16_t IPE_encapsulatedKeys[] = {0x0123, 0x4567, 0x89AB, 0xCDEF,
                                         0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD};

#pragma DATA_SECTION(secret_plain_byte_seq, ".ipe_const")
const uint16_t secret_plain_byte_seq[8] = {0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe};

uint16_t public_encrypted_byte_seq[8];
uint16_t public_plain_byte_seq[8];

void IPE_encapsulatedInit(void);
void IPE_encapsulatedBlink(void);

extern uint32_t return_address;
void overwrite_keys(void);

void main(void) {
    int i;
    WDTCTL = WDTPW | WDTHOLD;  // Stop watchdog timer

    puts("Trying to read secret directly:\n");

    for (i = 0; i < 8; i++)
    {
        printf("Byte: %x\n", secret_plain_byte_seq[i]);
    }

    overwrite_keys();  // overwrite the AES key from unprotected code

    IPE_encapsulatedInit();  // protected IPE setup code
    IPE_encapsulatedBlink();  // protected IPE code

    long tmp = &return_address;
    uint16_t return_address_L = tmp;
    uint16_t return_address_H = tmp>>16;

    AESACTL0 |= AESOP_1; // decrypt
    AESACTL0 |= AESKL_0; // key length == 128 bit

    for(i = 0; i < 8; i++)
    {
        if (i % 2 == 0)
            AESAKEY = return_address_L;
        else
            AESAKEY = return_address_H;
    }

    // load data
    for (i = 0; i < 8; i++)
    {
        AESADIN = public_encrypted_byte_seq[i];
    }

    while (AESASTAT & AESBUSY) {
        __no_operation();
    }

    puts("Decoded values with known key:\n");

    for (i = 0; i < 8; i++)
    {
        public_plain_byte_seq[i] = AESADOUT;
        printf("Byte: %x\n", public_plain_byte_seq[i]);
    }

}

/*
 * IPE_encapsulatedInit
 *
 * Function stored in the IPE area.
 * This function initializes any variables stored in the IPE area, because they
 * cannot be initialized by normal C-startup code because that is outside the
 * IPE area.
 */
#pragma CODE_SECTION(IPE_encapsulatedInit, ".ipe")
void IPE_encapsulatedInit(void)
{
    /*
     * IPE_encapsulatedCount initialized to 1 for 1 blink on first execution of
     * IPE_encapsulatedBlink()
     */
    IPE_encapsulatedCount = 1;
}

/*
 * IPE_encapsulatedBlink
 *
 * Function stored in the IPE area
 * This function represents the actual code that would be the
 * proprietary code IP to be hidden in the encapsulated area.
 *
 * In this case, it simply:
 * 1. Initializes the red LED
 * 2. Initializes a timer module for the delay between LED toggles
 * 3. Toggles the LED for a number of times set by the IPE_encapsulatedCount
 *    IPE variable.
 * 4. Clears all module registers used (Timer, GPIO) after the code finishes.
 *
 * It also demonstrates the use of a constant in the IPE area to load AES keys
 * into the AES module, and clearing the AES module key at the end again so that
 * the keys are not already loaded for use by any code outside IPE.
 */
#pragma CODE_SECTION(IPE_encapsulatedBlink, ".ipe")
void IPE_encapsulatedBlink(void)
{
    /*
     * Initialize GPIOs used by IPE code.
     * Set P4.6 up for the red LED output. Starts out low.
     */
    P4OUT &= ~BIT6;
    P4DIR |= BIT6;

    /*
     * Initialize the timer for setting the delay between red LED toggles
     * 50000/~1000000 = 50ms delay (20 times per second)
     */
    TA0CCTL0 = CCIE;
    TA0CCR0 = 50000;

    /*
     * Loading AES keys from IPE const section
     */
    for(IPE_i = 0; IPE_i < 8; IPE_i++)
        AESAKEY = IPE_encapsulatedKeys[IPE_i];

    // load data
    int i;
    for (i = 0; i < 8; i++)
    {
        AESADIN = secret_plain_byte_seq[i];
    }

    while (AESASTAT & AESBUSY) {}

    for (i = 0; i < 8; i++)
    {
        public_encrypted_byte_seq[i] = AESADOUT;
    }


    /*
     * Reset AES module so that keys and settings will be cleared, so it can't
     * be used by any code outside of the IPE area
     */
    AESACTL0 = AESSWRST;

    /*
     * Clear all registers used (IPE best practice to conceal what
     * IPE code does)
     * Clear the timer registers and port registers in this case
     */
    TA0CCTL0 = 0;
    TA0CCR0 = 0;
    TA0CCR1 = 0;
    TA0CCR2 = 0;
    TA0CTL = 0;
    TA0R = 0;
    P4DIR &= ~BIT6;
    P4OUT &= ~BIT6;

    /*
     * Clear General purpose CPU registers R4-R15
     *
     * Note: if passing parameters back to code outside IPE, you may need to
     * preserve some CPU registers used for this. See www.ti.com/lit/pdf/slau132
     * MSP430 C/C++ compiler guide section on How a Function Makes a Call and
     * How a Called Function Responds for more information about the registers
     * that the compiler uses for these parameters, R12-R15. Note that if too
     * many arguments are passed, the stack will be used as well.
     *
     * In this case the function is declared void(void), so there is no issue.
     */
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

    /*
     * At this point, it may also be desired to clear any RAM that was allocated
     * in the course of the function, because RAM is not cleared on
     * de-allocation. However, this is completely application-dependent and care
     * would need to be taken not to corrupt the stack that is needed by the
     * application for proper functioning. It may be better in cases like this
     * to either:
     * 1. Use no local variables, and therefore only use variables in
     *    FRAM IPE area, to have less concern (though there could still be some
     *    stack usage leaving things in RAM after execution).
     *    This is what is done in this example (see how even the loop counter
     *    IPE_i is placed in IPE rather than a local variable).
     * 2. If there is real concern about what could be placed in RAM, write the
     *    IPE routines in assembly so that the user can completely control RAM
     *    and stack usage.
     */
}

/*
 * TIMER0_A0_ISR
 *
 * Demonstrates placing an ISR in the IPE area. This ISR is used for the timer
 * delay for the LED toggling in the IPE area, and simply wakes the device.
 */
#pragma CODE_SECTION(TIMER0_A0_ISR, ".ipe:_isr")
#pragma vector=TIMER0_A0_VECTOR
__interrupt
void TIMER0_A0_ISR(void)
{
    __bic_SR_register_on_exit(LPM0_bits); //Wake the device on ISR exit
    __no_operation();
}
