    .include "macros.s"

    ;; imported symbols
    .global call_untrusted_cont
    .global entryFuncs
    .global maxEntryIndex
    .global ipe_base_stack
    .global ipe_sp
    .global return_to_untrusted

    ;; exported symbols
    .global call_untrusted
    .global ipe_entry

;     ;; timing variables
;     .global TA0R
;     .global call_untrusted_time
;     .global ipe_entry_time
;     .global calling_entry_time

;     .sect ".TI.persistent"
; call_untrusted_time:
;     .word 0
; ipe_entry_time:
;     .word 0
; calling_entry_time:
;     .word 0
; zero_time:
;     .word 1337

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; IPE STUBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .sect ".ipe_func"

; securely call an untrusted function
; r7: address of untrusted function
; r6: bitmap of function arguments
call_untrusted:
;     start_timer
    push_secret_regs
    clear_secret_regs
    clear_caller_save_regs
    disable_secret_stack
;     stop_timer
;     mov &TA0R, &call_untrusted_time
    bra #call_untrusted_cont


; single IPE entry point: disables interrupts, sets up secret stack, routes call to function or return address
ipe_entry:
;     start_timer
;     stop_timer
;     mov &TA0R, &zero_time
;     nop
;     nop
;     start_timer
    dint_all
    cmp #0x00, &ipe_sp
    jne stack_initialized
    mov #ipe_base_stack, &ipe_sp
stack_initialized:
    enable_secret_stack
    cmp #ipe_base_stack, &ipe_sp  ; heuristic: if stack pointer is in the initial position, assume it's an entry call, not a return from an untrusted function
    jeq calling_entry_func
    pop_secret_regs
;     stop_timer
;     mov &TA0R, &ipe_entry_time
    reta


; calling one of the entry points, not returning from an ocall
; r7 contains the index of the called function
; r12-r15 contain the arguments for the called function
calling_entry_func:
;     stop_timer
;     start_timer
    cmp r7, &maxEntryIndex
    jhs index_in_bounds
    mov #0, r7  ; set index to 0 if it was out of bounds
index_in_bounds:
    add r7, r7  ; (r7 = 2 * index)
    mov r7, r6  ; (r6 = 2 * index)
    add r7, r7  ; (r7 = 4 * index)
    add r6, r7  ; (r7 = 6 * index -- each entry in the table is 6 bytes)
    mova entryFuncs(r7), r6
;     stop_timer
;     mov &TA0R, &calling_entry_time
    calla r6
;     start_timer
    add #4, r7  ; get size of return argument
    mov.b entryFuncs(r7), r6
    clear_caller_save_regs
    disable_secret_stack
;     stop_timer
;     add &TA0R, &calling_entry_time
    bra #return_to_untrusted
