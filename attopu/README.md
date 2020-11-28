# ATTOPU - a 4 inst cpu from StackOverflow

Original post and src:

https://stackoverflow.com/questions/51592244/implementation-of-simple-microprocessor-using-verilog/51621153#51621153

ISA:

```
[15 OPCODE 13] | [12 SPECIFIC 0]
Opcode is always in the top three bits, the rest of the instruction depends on
the type:

ALU OP:
    add rd, rs1, rs2 -- rd = rs1 + rs2; z = (rd == 0)
  [15 2'b000 13] | [12 rd 11] | [10 rs1 9] | [8 rs2 7] | [6 RESERVED 0]

LD:
    mv rd, $data -- rd = $data
  [15 2'b001 13] | [12 rd 11] | [10 $data 0]

    ld rd, [ra] -- rd = MEM[ra]
  [15 2'b011 13] | [12 rd 11] | [10 ra 9] | [8 RESERVED 0]

ST:
    st rs, ra -- MEM[ra] = rs
  [15 2'b101 13] | [12 RESERVED 11] | [10 ra 9] | [8 rs 7] | [6 RESERVED 0]

BRZ:
    brz $addr -- if (z): pc = pc + $addr
  [15 2'b110 13] | [12 RESERVED 11] | [10 $addr 0]

    brz ra -- if (z): pc = ra
  [15 2'b111 13] | [12 RESERVED 11] | [10 ra 9] | [8 RESERVED 0]
```
