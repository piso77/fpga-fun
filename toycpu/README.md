# ATTOPU - a 4 inst cpu from StackOverflow

Original post and src:

https://stackoverflow.com/questions/51592244/implementation-of-simple-microprocessor-using-verilog/51621153#51621153

ISA:

```
[15 OPCODE 13] | [12 SPECIFIC 0]
Opcode is always in the top three bits, the rest of the instruction depends on
the type:

ALU OP:
  [15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 rs2 7] | [6 aluop 0]

    mv rd, rs1 -- rd = rs1 -- moving data between register is an ALU op
  [15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 RESERVED 7] | [6 7'b0000000  0]

    add rd, rs1, rs2 -- rd = rs1 + rs2; z = (rd == 0)
  [15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 rs2 7] | [6 7'b0000001 0]

LD IMMEDIATE:
    ld rd, $data -- rd = $data
  [15 2'b001 13] | [12 rd 11] | [10 $data 0]

UNUSED:
  [15 2'b010 13] | [12 RESERVED 0]

LD INDIRECT:
    ld rd, [ra] -- rd = MEM[ra]
  [15 2'b011 13] | [12 rd 11] | [10 ra 9] | [8 RESERVED 0]

UNUSED:
  [15 2'b100 13] | [12 RESERVED 0]

ST INDIRECT:
    st [ra], rs -- MEM[ra] = rs
  [15 2'b101 13] | [12 RESERVED 11] | [10 ra 9] | [8 rs 7] | [6 RESERVED 0]

BR C|NC|Z|NZ ABSOLUTE:
    brz $addr -- if (z): pc = $addr
  [15 2'b110 13] | [12 flags 11] | [10 $addr 0]

BRZ REGISTER:
    brz ra -- if (z): pc = ra
  [15 2'b111 13] | [12 RESERVED 11] | [10 ra 9] | [8 RESERVED 0]
```
