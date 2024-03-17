    .global FRCTL0_H
    .global GCCTL0_L
    .global old_GCCTL0_L
    .global old_SFRIE1
    .global SFRIE1
    .global untrusted_sp
    .global TA0CTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MACROS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; enables both maskable and non-maskable interrupts
eint_all .macro
    nop
    eint
    nop
    mov &old_SFRIE1, &SFRIE1
    mov.b #0xa5, &FRCTL0_H  ; GCCTL0 password protected
    mov.b &old_GCCTL0_L, &GCCTL0_L
    mov.b #0x00, &FRCTL0_H
    .endm

; disables both maskable and non-maskable interrupts
dint_all .macro
    dint
    nop
    mov &SFRIE1, &old_SFRIE1
    mov #0, &SFRIE1
    mov.b &GCCTL0_L, &old_GCCTL0_L
    mov.b #0xa5, &FRCTL0_H  ; GCCTL0 password protected
    and.b #10000111b, &GCCTL0_L
    mov.b #0x00, &FRCTL0_H
    .endm

; switches the stack pointer to use the trusted IPE stack
enable_secret_stack .macro
    mov r1, &untrusted_sp
    mov &ipe_sp, r1
    .endm

; switches the stack pointer back to the untrusted default stack
disable_secret_stack .macro
    mov r1, &ipe_sp
    mov &untrusted_sp, r1
    .endm

; pop callee-save registers (except for r6 and r7, carrying metadata about called untrusted function)
pop_secret_regs .macro
    pop r10
    pop r9
    pop r8
    pop r5
    pop r4
    .endm

; push callee-save registers (except for r6 and r7, carrying metadata about called untrusted function)
push_secret_regs .macro
    push r4
    push r5
    push r8
    push r9
    push r10
    .endm

; clear callee-save registers (except for r6 and r7, carrying metadata about called untrusted function)
clear_secret_regs .macro
    clr r4
    clr r5
    clr r8
    clr r9
    clr r10
    .endm

; clear caller-save registers except for those carrying a return value
; r6 contains the bitmap of the return value / argument pattern
clear_caller_save_regs .macro
    rra r6
    jc finished?
    clr r15
    rra r6
    jc finished?
    clr r14
    rra r6
    jc finished?
    clr r13
    rra r6
    jc finished?
    clr r12
finished?:  ; question mark to allow label in macro
    clr r2
    clr r11
    .endm

; set up MPU configuration and lock it to prevent modifications
mpu_lock .macro
    mov #0xA500, &MPUCTL0
    mov #mpu_segment_border1, &MPUSEGB1
    mov #mpu_segment_border2, &MPUSEGB2
    mov #mpu_sam_value, &MPUSAM
    mov #mpu_ctl0_value, &MPUCTL0
    mov.b #0, &MPUCTL0
    .endm

start_timer .macro
    mov #0x224, &TA0CTL
    .endm

stop_timer .macro
    mov #0, &TA0CTL
    .endm
