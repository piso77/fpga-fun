# LD	r0, $100:		01 00 00100000000 0		0100|0010|0000|0000	$4200
# LD	r1, $101:		01 01 00100000001 0		0101|0010|0000|0010	$5202
# LD	r3, $103:		01 11 00100000011 0		0111|0010|0000|0110	$7206
# ADD	r2, r0, r1:		00 10 00 01 00000000	0010|0001|0000|0000	$2100
# ST	r2, r3:			10 00 11 10 0000000 1	1000|1110|0000|0001	$E701