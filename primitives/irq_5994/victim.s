	.global victim
	.global secret
	.sect ".ipe"
secret:
	.word 1337
source:
	.space 20
dest:
	.space 20

victim:
	clr r15
	mov #source, r13
	mov #dest, r14
loop:
	mov 0(r13), 0(r14)
	add #2, r13
	add #2, r14
	inc r15
	cmp #10, r15
	jl loop
	ret
