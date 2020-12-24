.arch	toycpu
.org	0
.len	32
.width	16

	LD	r0, $80		; switches
	LD	r1, $81		; leds
	LD	r2, $01
Loop:
	LD	r3, [r0]	; read switches status
	ADD	r3, r2
	ST	[r1], r3	; write to led switches+1
	LD	r3, Loop
	BR	nz, [r3]
