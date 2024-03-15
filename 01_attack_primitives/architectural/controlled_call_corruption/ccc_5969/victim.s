	.global victim
	.global secret
	.global access_allowed
	.sect ".ipe"
secret:
	.word 1337
access_allowed:
	.word 0

victim:
        mov #0xffff, r15
        cmp #0, &access_allowed
        jeq .Lret
        mov &secret, r15
.Lret:
        ret
