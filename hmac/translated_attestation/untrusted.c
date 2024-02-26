/**
 * Memory attestation with HMAC, hardened with our software framework.
 * This file can be configured to either run the
 * attestation normally (and collect timing information), or perform
 * an attack chain to steal the secret attestation key.
 *
 * If the attack is to be performed, removed the comment from the line `#define ATTACK` (line 19).
 *
 * After launching the debug session, do a hard reset (to finish the setup), then run the code.
 *
 * To inspect the output, open the Memory Browser view.
 * When running the attestation normally, the `mac_region` array will have changed.
 * When performing the attack, the device will get into an infinite loop due to the
 * attack code triggering a reset, but the `buffer` array will never contain the secret key.
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
    P1DIR |= BIT0;
    PM5CTL0 &= ~LOCKLPM5;
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
        P1DIR |= BIT3;
        PM5CTL0 &= ~LOCKLPM5;
        P1OUT |= BIT3;
        P1OUT &= ~BIT3;

        attest();
    }

    P1DIR |= BIT3;
    P4DIR |= BIT6;
    PM5CTL0 &= ~LOCKLPM5;
    P1OUT |= BIT3;
    P1OUT &= ~BIT3;
    P4OUT |= BIT6;
#endif

    while (1) {
        __no_operation();
    }

    return 0;
}
