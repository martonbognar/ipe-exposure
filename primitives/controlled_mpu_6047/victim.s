	.sect ".ipe_const"
ipe1:
	.word 0x0

	; ensure ipe2 falls into a different MPU section
	.space 2000

ipe2:
	.word 2

	.sect ".ipe"
	.global victim
victim:
	mov &ipe1, r14
	cmp r14, r12
	jne cont
	mov &ipe1, r15
	jmp end
cont:
	mov &ipe2, r15
	jmp end
end:
	reta
