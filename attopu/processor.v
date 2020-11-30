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
	output [15:0] reg3,
	output cFlag,
	output zFlag
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
	wire cFlag;
	wire zFlag;
	wire [15:0] aluOut;

	wire [1:0] nextPCSel;
	reg [15:0] PC;
	reg [15:0] nextPC;
	wire halt;

	wire [15:0] instruction;

`ifdef DEBUG
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;
`endif

	reg [15:0] memArray [1023:0];
	initial begin
		// Load in the program/initial memory state into the memory module
		$readmemh("test.hex", memArray);
	end

	always @(posedge clk) begin
		if (memWE) begin // When the WE line is asserted, write into memory at the given address
			memArray[dAddr[9:0]] <= regOut2; // Limit the range of the addresses
		end
	end

	assign dDataOut = memArray[dAddr[9:0]];
	assign instruction = memArray[PC[9:0]];

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
		.cFlag(cFlag),
		.zFlag(zFlag)
	);

	decoder decode(
		.instruction(instruction),
		.cFlag(cFlag),
		.zFlag(zFlag),
		.nextPCSel(nextPCSel),
		.halt(halt),
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

    case (nextPCSel)
		// From instruction absolute
		2'b01: begin
			nextPC = addr;
		end

		// From register file
		2'b10: begin
			nextPC = regOut1;
		end

		// Regular operation, increment
		default: begin
			nextPC = PC + 16'd1;
		end
		endcase
	end

	// PC Register
	always @(posedge clk, posedge rst, posedge halt) begin
		if (rst) begin
			PC <= 16'd0;
		end
		else begin
			if (halt == 1'b0) begin
				PC <= nextPC;
			end
		end
	end

	// Extra logic
	assign regDataIn = (immData) ? addr : ((regDataInSource) ? dDataOut : aluOut);
	assign dAddr = (dAddrSel) ? regOut1 : addr;

	assign led = PC[7:0];
endmodule
