.arch	attopu
.org	0
.len	1024
.width	16

LD	r0, #$0a		; ld rd, $addr -- rd = MEM[$addr]
LD	r1, #$0b
ADD	r2, r0, r1
ST	r2, #$0a		; st rs, $addr	-- MEM[$addr] = rs -- 1010|0000|0001|0100 => A014
LD	r3, #$0e
ST	r2, r3			; st rs, ra		-- MEM[ra] = rs
RESET
RESET
RESET
RESET

; every data item is .width padded and decimal
.data 0010 0002 0003 0004 0015 0006
