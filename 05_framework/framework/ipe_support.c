#include "ipe_support.h"

extern int fram_ipe_start;
extern int fram_ipe_end;

int IPE_FUNC outside_IPE_segment(void *ptr)
{
    return (ptr < &fram_ipe_start) || (ptr >= &fram_ipe_end);
}

// Function copied from NaCL's libsodium, re-use allowed under ISC license.
int IPE_FUNC constant_time_cmp(const unsigned char *x_, const unsigned char *y_, const unsigned int n)
{
    const volatile unsigned char *volatile x = (const volatile unsigned char *volatile)x_;
    const volatile unsigned char *volatile y = (const volatile unsigned char *volatile)y_;
    volatile unsigned int d = 0U;
    unsigned int i;

    for (i = 0; i < n; i++)
    {
        d |= x[i] ^ y[i];
    }

    return (1 & ((d - 1) >> 8)) - 1;
}
