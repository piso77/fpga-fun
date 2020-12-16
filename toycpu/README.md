# ToyCPU - an FPGA/Verilog learning ground in the form of a home-grown cpu


* 16 general purpose 16bit wide registers: r0-r15
* 16bit fixed size word/instruction
* 4 instruction formats with 2 addressing modes (immediate and indirect):
```
4 ISA formats / 2 addressing modes (immediate / indirect):
[15 OPCODE 12|11 RD 8|7 RS 4|5 UNUSED 0]
[15 OPCODE 12|11 RD 8|7    DATA       0]
[15 OPCODE 12|11 FL 8|7    ADDR       0]
[15 OPCODE 12|11 FL 8|7 RS 4|5 UNUSED 0]
```

* 16 instructions:
```
MV (reg to reg), LD (indirect), ST (indirect) and every ALU (ADD, SUB, MUL, SHL, SHR, OR, AND, XOR, TST) operation:
[15 OPCODE 12|11 RD 8|7 RS 4|5 UNUSED 0]

LD immediate:
[15 OPCODE 12|11 RD 8|7    DATA       0]

BR immediate:
[15 OPCODE 12|11 FL 8|7    ADDR       0]

BR indirect:
[15 OPCODE 12|11 FL 8|7 RS 4|5 UNUSED 0]
```

Legend| Assembly token
------|------
OPCODE: instructions opcode            			| LD, MV, ADD, SUB, MUL, SHL, SHR, OR, AND, XOR, TST, BR (see toycpu.json)
RD: destination register                        | r0-r15
RS: source register                             | r0-r15
FL: branch flag (carry/!carry/zero/!zero)       | c/nc/z/nz
DATA: const data value                          | 8bit data (e.g. $ff)
ADDR: const addr value                          | 8bit addr (e.g. $ff or text label)


Original *StackOverflow* [post](https://stackoverflow.com/questions/51592244/implementation-of-simple-microprocessor-using-verilog/51621153#51621153) that inspired this work.
