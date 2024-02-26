    .global ecall_table
    .global max_ecall_index
    .sect ".ipe_const"
ecall_table:

    .global attest_internal
    .field attest_internal,32
    .byte 00000000b

max_ecall_index:
    .word 0
