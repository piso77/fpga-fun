# ToyCPU - an FPGA/Verilog learning ground in the form of a simple cpu

ToyCPU: a 16 (r0-r15) general purpose 16bit wide registers, 16 instructions set,
4 instruction formats and 2 addressing mode cpu.

Original post and src that inspired this work:

https://stackoverflow.com/questions/51592244/implementation-of-simple-microprocessor-using-verilog/51621153#51621153


```
4 ISA formats / 2 addressing modes (immediate / indirect):
[15 OPCODE 12|11 RD 8|7 RS 4|5 UNUSED 0]
[15 OPCODE 12|11 RD 8|7    DATA       0]
[15 OPCODE 12|11 FL 8|7    ADDR       0]
[15 OPCODE 12|11 FL 8|7 RS 4|5 UNUSED 0]

MV (reg to reg), LD (indirect), ST (indirect) and every ALU (ADD, SUB, MUL, SHL, SHR, OR, AND, XOR, TST) operations:
[15 OPCODE 12|11 RD 8|7 RS 4|5 UNUSED 0]

LD immediate:
[15 OPCODE 12|11 RD 8|7    DATA       0]

BR immediate:
[15 OPCODE 12|11 FL 8|7    ADDR       0]

BR indirect:
[15 OPCODE 12|11 FL 8|7 RS 4|5 UNUSED 0]

OPCODE: instructions opcode					| LD, MV, ADD, SUB, MUL, SHL, SHR, OR, AND, XOR, TST, BR (see toycpu.json)
RD: destination register					| r0-r15
RS: source register							| r0-r15
FL: branch flag (carry/!carry/zero/!zero) 	| c|nc|z|nz
DATA: const data value						| 8bit data
ADDR: const addr value						| 8bit addr
```
