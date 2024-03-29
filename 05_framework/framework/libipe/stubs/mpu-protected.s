    .include "macros.s"

    ;; imported symbols
    .global ipe_entry
    .global mpu_ctl0_value
    .global mpu_sam_value
    .global mpu_segment_border1
    .global mpu_segment_border2
    .global MPUCTL0
    .global MPUSAM
    .global MPUSEGB1
    .global MPUSEGB2
    .global PMMCTL0
    .global WDTCTL
    .global SYSRSTIV
    .global main

    ;; frequency control
    .global CSCTL0
    .global CSCTL1
    .global CSCTL3

    ;; exported symbols
    .global ipe_ocall_cont
    .global reset_into_ipe
    .global ecall_ret
    .global _system_pre_init
    .global _system_post_cinit
    .global reset_counter

;     ;; timing variables
;     .global TA0R
;     .global reset_into_time
;     .global pre_init_switched_time
;     .global pre_init_first_time
;     .global post_init_time
;     .global untrusted_cont_time
;     .global return_time
;     .global reset_entering_time
;     .global reset_normal_time


;     .sect ".TI.persistent"
; reset_into_time:
;     .word 0
; pre_init_switched_time:
;     .word 0
; pre_init_first_time:
;     .word 0
; post_init_time:
;     .word 0
; untrusted_cont_time:
;     .word 0
; return_time:
;     .word 0
; reset_entering_time:
;     .word 0
; reset_normal_time:
;     .word 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PERSISTENT STORAGE ACROSS RESETS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .sect ".TI.persistent"

reset_counter:
    .word 0

old_reset_isr:
    .field 0,16
entering_ipe:
    .field 0,16
old_r1:
    .field 0,32
old_r2:
    .field 0,32
old_r4:
    .field 0,32
old_r5:
    .field 0,32
old_r6:
    .field 0,32
old_r7:
    .field 0,32
old_r8:
    .field 0,32
old_r9:
    .field 0,32
old_r10:
    .field 0,32
old_r11:
    .field 0,32
old_r12:
    .field 0,32
old_r13:
    .field 0,32
old_r14:
    .field 0,32
old_r15:
    .field 0,32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; WRITE-PROTECTED (NON-IPE) STUBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .sect ".text"

; persist register contents and trigger a reset with entering IPE flag set
reset_into_ipe:
;     start_timer
    mov r1, &old_r1
    mov r2, &old_r2
    mov r4, &old_r4
    mov r5, &old_r5
    mov r6, &old_r6
    mov r7, &old_r7
    mov r8, &old_r8
    mov r9, &old_r9
    mov r10, &old_r10
    mov r11, &old_r11
    mov r12, &old_r12
    mov r13, &old_r13
    mov r14, &old_r14
    mov r15, &old_r15
    mov #1, &entering_ipe
;     stop_timer
;     mov &TA0R, &reset_into_time
    mov #0xA504, &PMMCTL0  ; trigger sw BOR
    ; no ret needed since reset triggers


; during regular (not into IPE) resets: disable watchdog, set up reset ISR (on first run), lock MPU
_system_pre_init:
;     start_timer
    mov #0x5A80, &WDTCTL
    mov #0xA500, &MPUCTL0
    cmp #0, &old_reset_isr
    jne reset_isr_already_switched
    mov &0xfffe, &old_reset_isr
    mov #new_reset_isr, &0xfffe
    ; on the first launch, we do not immediately lock the mpu configuration because globals still need to be initialized
    mov #1, r12
;     stop_timer
;     mov &TA0R, &pre_init_first_time
    reta
reset_isr_already_switched:
    mpu_lock
    mov #1, r12
;     stop_timer
;     mov &TA0R, &pre_init_switched_time
    reta


; on the first launch, lock mpu after globals have been initialized
_system_post_cinit:
;     start_timer
    mpu_lock
;     stop_timer
;     mov &TA0R, &post_init_time
    reta


; enables MPU protection, calls untrusted function, resets into IPE
; address of untrusted function passed in r7
ipe_ocall_cont:
;     start_timer
    mpu_lock
    mov #0, &entering_ipe
    eint_all
;     stop_timer
;     mov &TA0R, &untrusted_cont_time
    calla r7
    bra #reset_into_ipe


; returning to untrusted calling code from outside IPE region to prevent ROP
; attack due to uncontrolled return address
ecall_ret:
;     start_timer
    mpu_lock
    mov #0, &entering_ipe
    eint_all
;     stop_timer
;     mov &TA0R, &return_time
    reta


    .sect ".text:_isr"

; reset ISR: if entering IPE flag is set, restore registers and jump to entry,
; otherwise enable MPU protection and follow old reset vector
new_reset_isr:
    ; first set clock to 8 MHz in line with vrased experiments (any changes
    ; made in `main` are lost on reset, so need to be re-applied here)
    mov #0xA500, &CSCTL0 
    mov #0x0046, &CSCTL1
    mov #0, &CSCTL3
;     start_timer
    mov #0x5A80, &WDTCTL
    mov #0xA500, &MPUCTL0
    add #1, &reset_counter
    cmp #0, &entering_ipe
    jeq normal_reset
    mov &old_r1, r1
    mov &old_r2, r2
    mov &old_r4, r4
    mov &old_r5, r5
    mov &old_r6, r6
    mov &old_r7, r7
    mov &old_r8, r8
    mov &old_r9, r9
    mov &old_r10, r10
    mov &old_r11, r11
    mov &old_r12, r12
    mov &old_r13, r13
    mov &old_r14, r14
    mov &old_r15, r15
;     stop_timer
;     mov &TA0R, &reset_entering_time
    br #ipe_entry
normal_reset:
    mpu_lock
;     stop_timer
;     mov &TA0R, &reset_normal_time
    br &old_reset_isr

; overwrite IVT entries
    .sect ".int53"
    .word new_reset_isr
    .sect ".int54"
    .word new_reset_isr
