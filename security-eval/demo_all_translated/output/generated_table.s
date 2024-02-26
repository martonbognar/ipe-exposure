    .global entryFuncs
    .global maxEntryIndex
    .sect ".ipe_const"
entryFuncs:

    .global protected_internal
    .field protected_internal,32
    .byte 00000000b

maxEntryIndex:
    .word 0
