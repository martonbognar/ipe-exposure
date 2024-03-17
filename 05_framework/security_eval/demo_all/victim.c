#include <msp430.h>
#include <stdint.h>
#include <stdio.h>
#include <ipe_support.h>

const IPE_VAR uint16_t key[] = {0x0123, 0x4567, 0x89AB, 0xCDEF};

extern uint16_t public;

/*
 * 00000000 <protected>:
   0:   40 18 1c 42     movx.w  &0x00000,r12    ;
   4:   00 00
   6:   40 18 1c 52     addx.w  &0x00000,r12    ;
   a:   00 00
   c:   3c 80 2a 00     sub     #42,    r12     ;#0x002a
  10:   cd 0c           mova    r12,    r13     ;
  12:   b0 13 00 00     calla   #0              ;__mspabi_mpyi
  16:   82 4c 00 00     mov     r12,    &0x0000 ;
  1a:   10 01           reta                    ;
 *
 */
void IPE_ENTRY protected(void) {
    // pretend that this is a very difficult to reverse operation
    int temp = key[0];
    temp += key[0];
    temp -= 42;
    /* NOTE: shifting with a non-power-of-two will require help from a compiler-inserted support routine.. */
    temp = temp * temp;
    public = temp;
}
