/**
 * Helloworld to test IPE functionality.
 *
 * How to run:
 * 1. Load program, run until you see the output.
 * 2. Hard reset, run program again (now with IPE enabled).
 *
 * Expected output:
 * ----------
 * Reading secret from main: 1234 (IPE disabled)
 * Reading secret from IPE : 1234
 * ----------
 * Reading secret from main: 3fff (IPE enabled)
 * Reading secret from IPE : 1234
 * ----------
 *
 * Explanation:
 * 0: IPE is not yet activated, key is visible.
 * 1: IPE is activated in the default configuration, reading the key returns the default 3fff value.
 */

#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

/******************** PROTECTED IPE CODE *********************/

#pragma DATA_SECTION(ipe_secret, ".ipe_vars")
uint16_t ipe_secret[3] = {0x1234, 0x5678, 0x9abc};

#pragma CODE_SECTION(ipe_function, ".ipe")
void ipe_function(void)
{
    printf("Reading secret from IPE : %x\n", ipe_secret[0]);
}

/******************** UNPROTECTED ATTACKER CODE *********************/

void _system_post_cinit(void)
{
    puts("\n----------");
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   //Stop watchdog timer

    P4DIR |= BIT6;
    P1DIR |= BIT0;
    P4OUT &= ~BIT6;
    P1OUT &= ~BIT0;
    PM5CTL0 &= ~LOCKLPM5;

    uint16_t secret = ipe_secret[0];
    printf("Reading secret from main: %x (%s)\n",
           secret, secret == 0x1234 ? "IPE disabled" : "IPE enabled");

    ipe_function();
    return 0;
}
