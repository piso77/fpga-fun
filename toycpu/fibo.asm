; Fibonacci sequence calculation
.arch	toycpu
.org	0
.len	128
.width	16

Start:
		LD	r0, $0
		LD	r1, $1
Loop:
		ADD	r0, r1	; newA <= A + B
		MV	r2, r0
		MV	r0, r1		; A <= B
		MV	r1, r2		; B <= newA
		BR	NC, Loop
