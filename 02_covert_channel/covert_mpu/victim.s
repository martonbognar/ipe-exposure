	.global victim
	.global secret
	.global seg1
	.global seg2
	.global seg3

	.sect ".ipe_const"
seg1:
	.word 0

	.space 2000

seg2:
	.word 0

	.space 2000

seg3:
	.word 0

secret:
	.word 0xBEEF

	.sect ".ipe"
victim:
	; bit to leak in r12
	bit r12, &secret
	jz firstzero
	mov #1, &seg1
firstzero:
	rla r12 ; move bit in r12
	bit r12, &secret
	jz secondzero
	mov #1, &seg2
secondzero:
	rla r12 ; move bit in r12
	bit r12, &secret
	jz thirdzero
	mov #1, &seg3
thirdzero:
	rla r12 ; move bit in r12
	ret
