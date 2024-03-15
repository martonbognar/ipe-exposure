    .global reset_into_ipe
    .global ipe_ocall


    .global attest
    .sect ".text"
attest:
    push r7
    mov #0, r7
    calla #reset_into_ipe
    pop r7
    reta

    .global signal_done
    .global signal_done_stub
    .sect ".ipe_func"
signal_done_stub:
    push r6
    push r7
    mov #00000000b, r6
    mova #signal_done, r7
    calla #ipe_ocall
    pop r7
    pop r6
    reta
