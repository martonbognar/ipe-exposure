/**
 * Unintended control flow due to arbitrary entry points in IPE.
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * Expected output:
 * ----------------
 * Secret directly: 3fff, storage: 1337
 * ----------------
 */

#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>

void attacker(void);
extern uint16_t storage;
extern uint16_t secret;

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    attacker();

    printf("Secret directly: %x, storage: %d\n", secret, storage);

    return 0;
}
