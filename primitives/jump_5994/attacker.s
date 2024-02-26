    .global victim
    .global storage
    .global attacker
    .global secret
    .sect ".att_ram_code"
storage:
	.word 0
attacker:
	mov #secret, r13
	mov #storage, r14

	mov #victim+10, r15
	call r15
	reta
