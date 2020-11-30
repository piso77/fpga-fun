; Fibonacci sequence calculation
.arch	attopu
.org	0
.len	1024
.width	16

LD	r0, #$0
LD	r1, #$1
ADD	r2, r0, r1	; newA <= A + B
MV	r0, r1		; A <= B
MV	r1, r2		; B <= newA
BR	NC, #$2
