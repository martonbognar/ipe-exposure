/**
 * Nemesis: measure execution time of individual instructions through interrupt delays.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Latency: 1 cycles, next PC: 480c
 * Latency: 3 cycles, next PC: 4810
 * Latency: 5 cycles, next PC: 4816
 * Latency: 3 cycles, next PC: 1de4
 */

#include <msp430.h>
#include <stdio.h>
#include <stdint.h>

void attacker(void);
extern uint16_t latencies;
uint16_t *array = &latencies;
extern uint16_t pcs;
uint16_t *pa = &pcs;

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    attacker();

    int i;
    for (i = 0; i < 4; ++i) {
        printf("Latency: %d cycles, next PC: %x\n", array[i], pa[i]);
    }

    return 0;
}
