#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>

// This program tests the inverse situation of the CALL exploit: a IPE function calling an unprotected function with SP pointing inside IPE.
// The return address is not written to IPE, confirming the hypothetical cause of the CALL exploit.

/**
 * First, run the program with no reset, observe how the key is corrupted:
 *
 * Expected output:
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 * 484e 0 89ab cdef aaaa bbbb cccc dddd
 *
 *
 * Then, stop and relaunch the debug session, and perform a hard reset (to activate IPE)
 * before starting the program, and observe how the corruption is prevented:
 *
 * Expected output:
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 * 123 4567 89ab cdef aaaa bbbb cccc dddd
 *
 */

#pragma DATA_SECTION(key, ".ipe_const")
const uint16_t key[] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD};

uint16_t sp_buffer;
void ipe_attacker(void);

uint16_t counter = 0;

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
    counter++;
    if (counter < 2) {
        print_key();
        ipe_attacker();
    }
    return 0;
}
