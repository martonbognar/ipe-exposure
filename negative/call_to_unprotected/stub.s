    .global sp_buffer
    .global ipe_attacker
    .global untrusted
    .global key
    .global print_key

    .sect ".ipe"
ipe_attacker:
	mov SP, &sp_buffer
	mov #key+4, SP
	calla #untrusted_handler

	.sect ".text"
untrusted_handler:
	mov &sp_buffer, SP
	calla #print_key
	reta
