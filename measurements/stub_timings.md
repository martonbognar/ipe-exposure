reset_into_time
-2 + 47 + `mov #0xA504, &PMMCTL0` (4) = 49
pre_init_switched_time
-2 + 39 + `reta` (5) = 42
pre_init_first_time
-2 + 25 + `reta` (5) = 28
post_init_time
-2 + 25 + `reta` (5) = 28
untrusted_cont_time
-2 + 48 + `calla r7` (5) + `bra #reset_into_ipe` (3) = 54
return_time
-2 + 48 + `reta` (5) = 51
reset_entering_time
-2 + 61 + `br #ipe_entry` (3) = 62
reset_normal_time
-2 + 42 + `br &old_reset_isr` (5) = 45
call_untrusted_time
-2 + 46 + `bra #call_untrusted_cont` (3) = 47
ipe_entry_time
-2 + 56 + `mov #ipe_base_stack, &ipe_sp` (4) + `reta` (5) = 63
calling_entry_time
-2 + 45 + `calla r6` (5) + `bra #return_to_untrusted` (3) = 51

ipe_stub:
    push r7 (3)
    mov #0, r7 (1)
    calla #reset_into_ipe (5)
    pop r7 (2)
    reta (5) = 16

unprot_stub:
    push r6 (3)
    push r7 (3)
    mov #00000000b, r6 (2)
    mova #signal_done, r7 (3)
    calla #call_untrusted (5)
    pop r7 (2)
    pop r6 (2)
    reta (5) = 25


zero_time
2

reta: MOVA @SP+,PC (5)
bra: MOVA dst,PC (3)
br: MOV dst,PC
pop MOV @SP+,dst
