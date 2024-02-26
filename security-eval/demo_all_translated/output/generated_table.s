    .global entryFuncs
    .global entryCount
    .sect ".ipe_const"
entryFuncs:

    .global protected_internal
    .field protected_internal,32
    .byte 00000000b

entryCount:
    .word 1
