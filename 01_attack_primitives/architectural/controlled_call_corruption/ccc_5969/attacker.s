    .global victim
    .global storage
    .global attacker
    .global secret
    .global access_allowed
    .sect ".att_ram_code"
storage:
	.word 0x0
sp_bu:
    .word 0x0
attacker:
    mov r1, &sp_bu

    mov #access_allowed+2, r1
    call #victim

    mov &sp_bu, r1
    mov r15, &storage
	reta
