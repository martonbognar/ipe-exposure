    .global entryFuncs
    .global maxEntryIndex
    .sect ".ipe_const"
entryFuncs:

    .global attest_internal
    .field attest_internal,32
    .byte 00000000b

maxEntryIndex:
    .word 0
