.arch	toycpu
.org	0
.len	128
.width	16

	LD	r0, $80
	MV	r2, r0
	LD	r1, $01
Loop:
	ADD	r2, r1
	ST	[r0], r2
	LD	r3, $80
	LD	r0, [r3]
	LD	r3, Loop
	BR	nz, [r3]
