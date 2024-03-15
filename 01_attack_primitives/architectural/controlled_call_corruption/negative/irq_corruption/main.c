#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

void attacker();

/**
 * Implicit writes on the MSP430 architecture are not only performed by call instructions.
 * Interrupt handlers push the interrupted instruction's address and the status register to the stack.
 * We thoroughly examined the behavior of this mechanism, as it appears similar to the call instruction,
 * but we found that the access control was indeed correctly enforced, even when the interrupted code
 * and the ISR also resided in the IPE region.
 */

/*
 * First, run the program normally without a reset, observe the corruption of the key:
 *
 * Expected output:
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 * 123 4567 f008 89aa aaaa bbbb cccc dddd
 *
 * Then, relaunch the debug session, do a hard reset (to enable IPE), and observe the key no longer getting corrupted:
 *
 * Expected output:
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 */

#pragma DATA_SECTION(key, ".ipe_const")
const uint16_t key[] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD};

uint16_t sp_buffer;

#pragma CODE_SECTION(print_key, ".ipe")
void print_key(void)
{
    for (int i = 0; i < 8; ++i) {
        printf("%x ", key[i]);
    }
    putchar('\n');
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;  // Stop watchdog timer
    print_key();
    attacker();
    print_key();
    return 0;
}

