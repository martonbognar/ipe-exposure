/**
 * Controlled channel attack with the MPU: detect whether IPE tried to access a given memory region.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Violation detected: first run: false, second run: true
 */

#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>

uint16_t res1;
uint16_t res2;

void victim(int);

void attacker(void) {

    victim(0);
    res1 = MPUCTL1 & MPUSEG2IFG;

    victim(1);
    res2 = MPUCTL1 & MPUSEG2IFG;
}

char *print_bool(int x) {
    return x ? "true" : "false";
}

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
    MPUCTL0 = MPUPW;
    MPUSEGB1 = 0x4C00 >> 4;
    MPUSEGB2 = 0x5000 >> 4;
    MPUSAM = MPUSEG1RE | MPUSEG1WE | MPUSEG1XE | MPUSEG3RE | MPUSEG3WE | MPUSEG3XE; // disable access to segment 2
    MPUCTL0 = MPUPW | MPUENA | MPULOCK;
    MPUCTL0_H = 0; // protect MPU registers

    attacker();
    printf("Violation detected: first run: %s, second run: %s\n", print_bool(res1), print_bool(res2));

	return 0;
}
