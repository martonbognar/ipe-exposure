	.global call_attacker
	.global key
	.global protected_internal

	.sect .data

backup:
	.word 0
	.word 0

	.sect .text

call_attacker:
	mova SP, &backup
	mov #key+4, SP
	calla #protected_internal
	mova &backup, SP
	reta
