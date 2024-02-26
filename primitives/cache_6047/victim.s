	.global victim
	.global TA0CTL
	.global TA0R
	.global pwd

	.sect ".ipe_const"
dummy:
	.word 1337

padding:
	.word 0, 0, 0, 0, 0, 0, 0, 0

secret:
	.word 1337

	.sect ".ipe"
victim:
	cmp &secret, r12
	jeq else
	nop
	nop
	nop
	nop
	jmp end
else:
	mov &pwd, r15
	jmp end
end:
	reta
