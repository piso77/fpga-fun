.arch	attopu
.org	0
.len	1024
.width	16

MV	r0, #$0a		; ld rd, $data	-- rd = $data
MV	r1, #$02
ADD	r2, r0, r1
ST	[r0], r2		; st [ra], rs	-- MEM[ra] = rs
MV	r3, #$0a
LD	r1, [r3]		; ld rd, [ra]	-- rd = MEM[ra]
RESET
RESET
RESET
RESET

; every data item is .width padded and decimal
.data 0010 0002 0003 0004 0015 0006
