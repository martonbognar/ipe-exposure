#include <msp430.h>
#include <stdint.h>
#include <stdio.h>
#include "ipe_support.h"

const IPE_CONST uint16_t key[] = {0x0123, 0x4567, 0x89AB, 0xCDEF};

extern uint16_t public;

 __attribute__((section(".ipe_entry"), retain)) void protected_internal(void)
{
  int temp = key[0];
  temp += key[0];
  temp -= 42;
  public = temp;
}
