    .global reset_into_ipe
    .global call_untrusted


    .global protected
    .sect ".text"
protected:
    push r7
    mov #0, r7
    calla #reset_into_ipe
    pop r7
    reta
