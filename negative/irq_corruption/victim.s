	.sect ".ipe"
	.global isr_ipe
	.global TA0CTL
	.global attack_end
	.global ipe_nop

isr_ipe:
	mov #0,&TA0CTL
	bra #attack_end

ipe_nop:
	nop
	nop
	nop
	nop
	nop
	reta

	.sect ".int45"
iv_45:
	.word isr_ipe
