	.global victim
	.global secret
	.global seg1
	.global seg2
	.global seg3

	.sect ".ipe_const"
secret:
	.word 0xdead

spaces1:
	.word 1, 2, 3, 4
spaces2:
	.word 5, 6, 7, 8

	.sect ".ipe"
victim:
	and &secret, r12
	rra &secret ; prepare for next iteration
	rra &secret

	add r12, r12
	add r12, r12
	add r12, r12
	add r12, r12 ; r12 *= 16 (0, 16, 32, 48)

	mov #spaces1, r7
	mov #spaces2, r8
	mov #0x1C00, r9

	add #table, r12

	br r12
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

; offset 0: 00, access ram dummy twice
; offset 1: 01, access first, then dummy
; offset 2: 10, access second, them dummy
; offset 3: 11, access first, then second

table:
	; offset 0, 4 words
	mov @r9, r11
	mov @r9, r11
	nop
	nop
	nop
	nop
	nop
	nop
offset16:
	; offset 8, 4 words
	mov @r7, r11
	mov @r9, r11
	nop
	nop
	nop
	nop
	nop
	nop
offset32:
	; offset 16, 4 words
	mov @r9, r11
	mov @r8, r11
	nop
	nop
	nop
	nop
	nop
	nop
offset48:
	; offset 24
	mov @r7, r11
	mov @r8, r11
	nop
	nop
	nop
	nop
	nop
	nop
end:
	ret
