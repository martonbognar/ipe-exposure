	.global irq_attacker
	.global protected_internal
	.global TA0CTL
	.global TA0CCR0
	.global buffer

	.sect .text
irq_attacker:
	eint
	; set up timer
    mov #0x4, &TA0CTL
    mov #4, &TA0CCR0
    mov #0x216, &TA0CTL
	calla #protected_internal
	reta


	.sect .data
buffer:
	.word 0

	.sect ".text:_isr"
custom_isr:
    mov #0x0, &TA0CTL
    mov r12, &buffer
	mov #1337, r12
	reti

	.sect ".int44"
iv_45:
	.word custom_isr
