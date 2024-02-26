	.sect ".ipe"
	.global victim
datae:
	.word 0x34

victim:
	mov r15, r15       ; 1 cycle
	mov &datae, r15    ; 3 cycles
	add #0x42, &datae  ; 5 cycles
	ret                ; 3 cycles
