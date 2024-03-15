	.global IPE_encapsulatedInit
	.global IPE_encapsulatedKeys
	.global overwrite_keys
	.global return_address

	.sect ".text"
overwrite_keys:
	mov SP,r4

	mov #IPE_encapsulatedKeys,SP
	mov #0,r6
begin_loop: ; loop variable is r6
	add #4,SP

	calla #IPE_encapsulatedInit

return_address: ; 32 bit (17 bit + zeros)
	inc r6
	cmp #4,r6
	jne begin_loop

	mova r4,SP
	reta
