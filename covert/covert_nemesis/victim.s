	.sect ".ipe"
	.global victim

secret:
	.word 0xBEEF
dummy:
	.word 0

victim:
	and &secret, r12
	rra &secret ; prepare for next iteration
	rra &secret
	cmp #0, r12

	add r12, r12
	add r12, r12 ; r12 *= 4 (0, 4, 8, 12)

	add #table, r12

	br r12

table:
	mov r15, r15       ; offset 0: 1 cycle
	nop
	mov &dummy, r15    ; offset 4: 3 cycles
	rra &dummy         ; offset 8: 4 cycles
	add #0x42, &dummy  ; offset 12: 5 cycles

end:
	ret
