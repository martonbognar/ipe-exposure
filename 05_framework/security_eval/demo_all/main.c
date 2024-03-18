#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

#define SECRET_KEY_BYTE     0x0123
#define DECLASSIFIED_OUTPUT 0x7310

uint16_t public = 0;
extern uint16_t key[];
void protected(void);
void call_attacker(void);
void jump_attacker(void);
void irq_attacker(void);

extern uint16_t buffer;

/*
 * NOTE: we define reset_counter as weak here, so that it is overridden
 * by our framework if the MPU stubs are included (ie compiled with mitigation enabled).
 */
#pragma WEAK(reset_counter)
#pragma PERSISTENT(reset_counter)
int reset_counter = 0;

#pragma WEAK(_system_post_cinit)
void _system_post_cinit(void)
{
    reset_counter++;
}

int expected_public = 0;

int step = 0;
int fail_code = 0;
#define ASSERT_STEP(cond, code) \
    if ( !(cond) ) { fail_code = code; while(1){ __no_operation();} } else { step++; }

/* NOTE: set this to the desired attack vector */
int attack = 2;

int main(void)
{
    int secret;
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	secret = key[0];
	printf("Key directly: %x (%s)\n", secret, secret == 0x3fff ? "IPE enabled" : "IPE disabled");

    if (secret != 0x3fff)
    {
        puts("fatal: IPE not enabled: pause the running debug session and trigger a hard reset via the CCS IDE..");
        fail_code = 1;
        while(1);
    }

    /* when using the MPU framework, this will reset and detach the console, so we can't printf after this */
    protected();
    ASSERT_STEP(public == DECLASSIFIED_OUTPUT, /*code=*/2 )
    expected_public = public;
    public = 0;

    switch (attack)
    {
        case 1:
            /* 1. Jump attack: jumps to the middle with fake key and corrupts the calculation */
            jump_attacker();
            ASSERT_STEP( public != DECLASSIFIED_OUTPUT, /*code=*/3)
            break;
        case 2:
             /* 2. IRQ attack: steals original key and corrupts the calculation */
            irq_attacker();
            ASSERT_STEP( public != DECLASSIFIED_OUTPUT, /*code=*/4)
            ASSERT_STEP( buffer == SECRET_KEY_BYTE , /*code=*/5)
            break;
        case 3:
            /* 3. CALL attack: corrupts the key and, thus, the calculation */
            call_attacker();
            ASSERT_STEP( public != DECLASSIFIED_OUTPUT, /*code=*/6)
            break;
    }

    /* If we reach here all attacks succeeded! */
    while (1)
    {
        __no_operation();
    }

	return 0;
}
