module processor(
	input clk,
	input rst,
`ifdef DEBUG
	output [15:0] instruction,
	output [15:0] PC,
	output [15:0] regOut1,
	output [15:0] regOut2,
	output [15:0] reg0,
	output [15:0] reg1,
	output [15:0] reg2,
	output [15:0] reg3
`else
	output [7:0] led
`endif
);

	wire [15:0] dAddr;
	wire [15:0] dDataOut;
	wire memWE;
	wire dAddrSel;

	wire [15:0] addr;

	wire [15:0] regDataIn;
	wire [1:0] regInSel;
	wire regFileWE;
	wire regDataInSource;
	wire immData;
	wire [1:0] regOutSel1;
	wire [1:0] regOutSel2;
	wire [15:0] regOut1;
	wire [15:0] regOut2;

	wire [6:0] aluOp;
	wire zFlag;
	wire [15:0] aluOut;

	wire [1:0] nextPCSel;
	reg [15:0] PC;
	reg [15:0] nextPC;

	wire [15:0] instruction;

`ifdef DEBUG
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;
`endif

	memory mem(
		.clk(clk),
		.iAddr(PC), // The instruction port uses the PC as its address and outputs the current instruction, so connect these directly
		.iDataOut(instruction),
		.dAddr(dAddr),
		.dWE(memWE),
		.dDataIn(regOut2), // In all instructions, only source register 2 is ever written to memory, so make this connection direct
		.dDataOut(dDataOut)
	);

	registerFile regFile(
`ifdef DEBUG
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
`endif
		.clk(clk),
		.rst(rst),
		.we(regFileWE),
		.inReg(regInSel),
		.dataIn(regDataIn),
		.outReg1(regOutSel1),
		.outReg2(regOutSel2),
		.dataOut1(regOut1),
		.dataOut2(regOut2)
	);

	ALU alu(
		.clk(clk),
		.rst(rst),
		.op(aluOp),
		.in1(regOut1),
		.in2(regOut2),
		.out(aluOut),
		.zFlag(zFlag)
	);

	decoder decode(
		.instruction(instruction),
		.zFlag(zFlag),
		.nextPCSel(nextPCSel),
		.regDataInSource(regDataInSource),
		.immData(immData),
		.regInSel(regInSel),
		.regFileWE(regFileWE),
		.regOutSel1(regOutSel1),
		.regOutSel2(regOutSel2),
		.aluOp(aluOp),
		.memWE(memWE),
		.dAddrSel(dAddrSel),
		.addr(addr)
	);

	// PC Logic
	always @(*) begin
		nextPC = 16'd0;

    casez (nextPCSel)
    // From register file
		2'b1?: begin
			nextPC = regOut1;
		end

		// From instruction relative
		2'b01: begin
			nextPC = PC + addr;
		end

		// Regular operation, increment
		default: begin
			nextPC = PC + 16'd1;
		end
		endcase
	end

	// PC Register
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			PC <= 16'd0;
		end
		else begin
			PC <= nextPC;
		end
	end

	// Extra logic
	assign regDataIn = (immData) ? addr : ((regDataInSource) ? dDataOut : aluOut);
	assign dAddr = (dAddrSel) ? regOut1 : addr;

	assign led = PC[7:0];
endmodule
