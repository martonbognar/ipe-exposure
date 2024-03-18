/**
 * Memory attestation with HMAC. This file can be configured to either run the
 * attestation normally (and collect timing information), or perform
 * an attack chain to steal the secret attestation key.
 *
 * If the attack is to be performed, removed the comment from the line `#define ATTACK` (line 18).
 *
 * After launching the debug session, do a hard reset (to activate IPE), then run the code.
 *
 * To inspect the output, open the Memory Browser view.
 * When running the attestation normally, the `mac_region` array will have changed.
 * When performing the attack, the `buffer` array will contain the first
 * few bytes (0x41, 0x41, ...) of the secret key.
 */
#include <msp430.h>
#include <stdint.h>

// #define ATTACK

// trusted
void attest(void);

// untrusted
void make_steal_gadget(void);
void use_gadget(void);

uint8_t mac_region[33] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

void signal_done(void) {
    P1OUT |= BIT0;
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;                 // Stop Watchdog

    P1DIR |= BIT3;
    P1DIR |= BIT0;
    P1OUT &= ~BIT3;
    P1OUT &= ~BIT0;

    PM5CTL0 &= ~LOCKLPM5;

    CSCTL0_H = PMMPW_H;
    CSCTL1 = DCORSEL | DCOFSEL_3;  // set clock to 8 MHz in line with vrased experiments
    CSCTL3 = DIVS_0 | DIVM_0;

#ifdef ATTACK
    make_steal_gadget();
    use_gadget();
#else
    for (int i = 0; i < 100; ++i) {
        P1OUT |= BIT3;
        P1OUT &= ~BIT3;

        attest();
    }

    P1OUT |= BIT3;
    P1OUT &= ~BIT3;
#endif

    while (1) {
        __no_operation();
    }

    return 0;
}
