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

int main(void)
{
    int i, secret;
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	secret = key[0];
	printf("Key directly: %x (%s)\n", secret, secret == SECRET_KEY_BYTE ? "IPE disabled" : "IPE enabled");
	protected();
	printf("Value of declassified: %x\n", public);

	if (secret == SECRET_KEY_BYTE)
	{
	    puts("fatal: IPE not enabled: pause the running debug session and trigger a hard reset via the CCS IDE..");
	    while(1);
	}

	for (i = 0; i < 2; i++)
	{
	    printf("\n=== ROUND %d: attack %s ===\n", i, i > 0 ? "enabled" : "disabled");

        puts("1. Jump attack: jumps to the middle with fake key and corrupts the calculation");
        if (i > 0) jump_attacker();
        printf("\tL_ Value of declassified after attack: %x \t\t\t[%s]\n", public, public != DECLASSIFIED_OUTPUT ? "OK" : "FAIL");

        puts("2. IRQ attack: steals original key and corrupts the calculation");
        if (i > 0) irq_attacker();
        printf("\tL_ Value of buffer: %x                    \t\t\t[%s]\n", buffer, buffer == SECRET_KEY_BYTE ? "OK" : "FAIL");
        printf("\tL_ Value of declassified after attack: %x \t\t\t[%s]\n", public, public != DECLASSIFIED_OUTPUT ? "OK" : "FAIL");

        puts("3. CALL attack: corrupts the key and, thus, the calculation");
        if (i > 0) call_attacker();
        printf("\tL_ Value of declassified after attack: %x \t\t\t[%s]\n", public, public != DECLASSIFIED_OUTPUT ? "OK" : "FAIL");
	}

	puts("\nmain: all done; exiting..");
	return 0;
}
