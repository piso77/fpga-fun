# ToyCPU - an FPGA/Verilog learning ground in the form of a simple cpu

Original post and src that inspired this work:

https://stackoverflow.com/questions/51592244/implementation-of-simple-microprocessor-using-verilog/51621153#51621153


```
Improved ISA format - brain dump:

MV, LDI, LDR, STR, ADD, SUB, MUL, DIV, SHL, SHR, OR, AND, XOR, TST, BRI, BRR

[15 OPCODE 12|11 RD 8|7 RS 4|5 UNUSED 0]
[15 OPCODE 12|11 FL 8|7 RS 4|5 UNUSED 0]
[15 OPCODE 12|11 RD 8|7    DATA       0]
[15 OPCODE 12|11 FL 8|7    ADDR       0]

The ISA has 3 distincts instruction format (0, 1 and 2):

[15 OPCODE 13 | 12 RD 11 | 10 RS1 9|8 RS2 7|6 ALUOP 0]
[15 OPCODE 13 | 12 RD 11 | 10 UNU 8|7   DATA        0]
[15 OPCODE 13 | 12 FL 11 | 10 RS1 9|8 U 8|7  ADDR   0]

OPCODE, FORMAT: DESCRIPTION

ALU OPs: all ALU ops share the same OPCODE, but different ALUOPs

MV: moving data between register is an ALU op
mv rd, rs1 -- rd = rs1
[15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 UNU 7] | [6 7'b0000000 0]

ADD:
add rd, rs1, rs2 -- rd = rs1 + rs2; z = (rd == 0)
[15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 rs2 7] | [6 7'b0000001 0]


UNUSED:
...
[15 2'b001 13] | [12 RESERVED 0]


LD IMM:
ld rd, $data -- rd = data
[15 2'b010 13] | [12 rd 11] | [10 UNU 8] | [7 data 0]


LD IND:
ld rd, [rs1] -- rd = MEM[rs1]
[15 2'b011 13] | [12 rd 11] | [10 rs1 9] | [8 UNU 0]


UNUSED:
...
[15 2'b100 13] | [12 RESERVED 0]


ST IND:
st [rs1], rs2 -- MEM[rs1] = rs2
[15 2'b101 13] | [12 RESERVED 11] | [10 rs1 9] | [8 rs2 7] | [6 UNU 0]


BR C|NC|Z|NZ IMM:
brz $addr -- if ($flag): pc = addr
[15 2'b110 13] | [12 flags 11] | [10 UNU 8] | [7 addr 0]


BR C|NC|Z|NZ IND:
brz rs1 -- if ($flag): pc = [rs1]
[15 2'b111 13] | [12 flags 11] | [10 rs1 9] | [8 UNU 0]
```
