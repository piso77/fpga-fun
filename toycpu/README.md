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

[15 OPCODE 12 | 11 RD 10 | 9 RS1 8|7 RS2 6|5 ALUOP 0]
[15 OPCODE 12 | 11 RD 10 | 9 UNU 8|7     DATA      0]
[15 OPCODE 12 | 11 FL 10 | 9 RS1 8|7     ADDR      0]

OPCODE, FORMAT: DESCRIPTION

ALU OPs: all ALU ops share the same OPCODE, but different ALUOPs

MV: moving data between register is an ALU op
mv rd, rs1 -- rd = rs1
[15 2'b0000 12] | [11 rd 10] | [9 rs1 8] | [7 UNU 6] | [5 6'b0000000 0]

ADD:
add rd, rs1, rs2 -- rd = rs1 + rs2; z = (rd == 0)
[15 2'b0000 12] | [11 rd 10] | [9 rs1 8] | [7 rs2 6] | [5 6'b0000001 0]


UNUSED:
...
[15 2'b0001 12] | [11 RESERVED 0]


LD IMM:
ld rd, $data -- rd = data
[15 2'b0010 12] | [11 rd 10] | [9 UNU 8] | [7 data 0]


LD IND:
ld rd, [rs1] -- rd = MEM[rs1]
[15 2'b0011 12] | [11 rd 10] | [9 rs1 8] | [7 UNU 0]


UNUSED:
...
[15 2'b0100 12] | [11 RESERVED 0]


ST IND:
st [rs1], rs2 -- MEM[rs1] = rs2
[15 2'b0101 12] | [11 RESERVED 10] | [9 rs1 8] | [7 rs2 6] | [5 UNU 0]


BR C|NC|Z|NZ IMM:
brz $addr -- if ($flag): pc = addr
[15 2'b0110 12] | [11 flags 10] | [9 UNU 8] | [7 addr 0]


BR C|NC|Z|NZ IND:
brz rs1 -- if ($flag): pc = [rs1]
[15 2'b0111 12] | [11 flags 10] | [9 rs1 8] | [7 UNU 0]
```
