    .global reset_into_ipe
    .global ipe_ocall


    .global protected
    .sect ".text"
protected:
    push r7
    mov #0, r7
    calla #reset_into_ipe
    pop r7
    reta
