	.global jump_attacker
	.global protected

	.sect .text
jump_attacker:
	mov #42, r15
	calla #protected+16
	reta
