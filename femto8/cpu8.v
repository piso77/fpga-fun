// ALU operations
`define OP_ZERO		4'h0
`define OP_LOAD_A	4'h1
`define OP_INC		4'h2
`define OP_DEC		4'h3
`define OP_ASL		4'h4
`define OP_LSR		4'h5
`define OP_ROL		4'h6
`define OP_ROR		4'h7
`define OP_OR		4'h8
`define OP_AND		4'h9
`define OP_XOR		4'ha
`define OP_LOAD_B	4'hb
`define OP_ADD		4'hc
`define OP_SUB		4'hd
`define OP_ADC		4'he
`define OP_SBB		4'hf

module ALU(A, B, carry, aluop, Y);

	parameter N = 8;
	input [N-1:0] A;
	input [N-1:0] B;
	input carry;
	input [3:0] aluop;
	output [N:0] Y;

	always @(*)
		case (aluop)
			// unary operations
			`OP_ZERO:		Y = 0;
			`OP_LOAD_A:		Y = {1'b0, A};
			`OP_INC:		Y = A + 1;
			`OP_DEC:		Y = A - 1;
			// unary ops. that generate and/or use carry
			`OP_ASL:		Y = {A, 1'b0};
			`OP_LSR:		Y = {A[0], 1'b0, A[N-1:1]};
			`OP_ROL:		Y = {A, carry};
			`OP_ROR:		Y = {A[0], carry, A[N-1:1]};
			// binary ops
			`OP_OR:			Y = {1'b0, A | B};
			`OP_AND:		Y = {1'b0, A & B};
			`OP_XOR:		Y = {1'b0, A ^ B};
			`OP_LOAD_B:		Y = {1'b0, B};
			// binary ops that generate and/os use carry
			`OP_ADD:		Y = A + B;
			`OP_SUB:		Y = A - B;
			`OP_ADC:		Y = A + B + (carry ? 1 : 0);
			`OP_SBB:		Y = A - B - (carry ? 1 : 0);
		endcase
endmodule

/*
	Bits		Description

	00ddaaaa	A @ B -> dest
	01ddaaaa	A @ immediate -> dest
	11ddaaaa	A @ read [B] -> dest
	10000001	swap A <-> B
	1001nnnn	A -> write [nnnn]
	1010tttt	conditional branch

	dd = destination (00=A, 01=B, 10=IP, 11=none)
	aaaa = ALU operation (@ operator)
	nnnn = 4-bit constant
	tttt = flags test for conditional branch
*/

// destinations for COMPUTE instructions
`define DEST_A		2'b00
`define DEST_B		2'b01
`define DEST_IP		2'b10
`define DEST_NOP	2'b11

// instructions macros
`define I_COMPUTE(dest, op) {2'b00, (dest), (op)}
`define I_COMPUTE_IMM(dest, op) {2'b01, (dest), (op)}
`define I_COMPUTE_READB(dest, op) {2'b11, (dest), (op)}
`define I_CONST_IMM_A {2'b01, `DEST_A, `OP_LOAD_B}
`define I_CONST_IMM_B {2'b01, `DEST_B, `OP_LOAD_B}
`define I_JUMP_IMM {2'b01, `DEST_IP, `OP_LOAD_B}
`define I_STORE_A(addr) {4'b1001, (addr)}
`define I_BRANCH_IF(zv, zu, cv, cu) {4'b1010, (zv), (zu), (cv), (cu)}
`define I_CLEAR_CARRY {8'b10001000}
`define I_SWAP_AB {8'b10000001}
`define I_RESET {8'b10111111}

// convenience macros
`define I_ZERO_A `I_COMPUTE(`DEST_A, `OP_ZERO)
`define I_ZERO_B `I_COMPUTE(`DEST_B, `OP_ZERO)
`define I_BRANCH_IF_CARRY(carry) `I_BRANCH_IF(1'b0, 1'b0, carry, 1'b1)
`define I_BRANCH_IF_ZERO(zero) `I_BRANCH_IF(zero, 1'b1, 1'b0, 1'b0)
`define I_CLEAR_ZERO `I_COMPUTE(`DEST_NOP, `OP_ZERO)

module CPU(clk, reset, address, data_in, data_out, write);
	input clk, reset;
	output [7:0] address;
	input [7:0] data_in;
	output [7:0] data_out;
	output write;

	reg [7:0] IP;
	reg [7:0] A, B;
	reg [8:0] Y;
	reg [2:0] state;

	reg carry, zero;
	wire [1:0] flags = {zero, carry};

	reg [7:0] opcode;
	wire [3:0] aluop = opcode[3:0];
	wire [1:0] opdest = opcode[5:4];
	wire B_or_data = opcode[6];

	localparam S_RESET =  0;
	localparam S_SELECT = 1;
	localparam S_DECODE = 2;
	localparam S_COMPUTE = 3;
	localparam S_READ_IP = 4;

	ALU alu(
		.A(A),
		.B(B_or_data ? data_in : B),
		.Y(Y),
		.aluop(aluop),
		.carry(carry)
	);
endmodule
