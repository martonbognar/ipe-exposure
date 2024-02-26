	.global jump_attacker
	.global protected_internal

	.sect .text
jump_attacker:
	mov #42, r15
	calla #protected_internal+16
	reta
