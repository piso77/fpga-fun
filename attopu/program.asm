.arch	attopu
.org	0
.len	1024
.width	16

LD	r0, #$09
LD	r1, #$0a
LD	r3, #$0e
ADD	r2, r0, r1
ST	r2, r3
LD	r3, #$06
RESET
RESET
RESET

; every data item is .width padded
.data 0001 0002 0003 0004 0005 0006
