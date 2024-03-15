```
#include <msp430.h>
#include <stdint.h>
#include <stdio.h>

uint16_t public = 0;
extern uint16_t *key;
void protected(void);
void call_attacker(void);
void jump_attacker(void);
void irq_attacker(void);

extern uint16_t buffer;

const int attack = 0;

void _system_post_cinit(void) {
puts("Reset!");
}

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	/ stop watchdog timer
	
	printf("Key directly: %x\n", key[0]);

	protected();

	printf("Value of declassified: %x\n", public);

	switch (attack) {
	case 0:
puts("CALL attack: corrupts the key, leading to a different result");
call_attacker();
printf("Value of declassified after attack: %x\n", public);
break;
	case 1:
puts("Jump attack: jumps to the middle of the enclave with a fake key value in the register used for the calculation");
jump_attacker();
printf("Value of declassified after attack: %x\n", public);
break;
	case 2:
puts("IRQ attack: steals original key and corrupts the calculation");
irq_attacker();
printf("Value of buffer: %x\n", buffer);
printf("Value of declassified after attack: %x\n", public);
break;
	}



	return 0;
}

```
