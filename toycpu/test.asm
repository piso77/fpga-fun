.arch	toycpu
.org	0
.len	128
.width	16

LD	r0, $0a		; ld rd, $data	-- rd = $data
MV	r2, r0
LD	r1, $02
ADD	r2, r1
ST	[r0], r2		; st [ra], rs	-- MEM[ra] = rs
LD	r3, $0a
LD	r1, [r3]		; ld rd, [ra]	-- rd = MEM[ra]
MV	r2, r3
LD	r2, $3
BR	nz, [r2]
