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

	wire [15:0] instrData;

	wire [15:0] regDataIn;
	wire [1:0] regDst;
	wire regFileWE;
	wire regDataInSource;
	wire immData;
	wire [1:0] regSrc1;
	wire [1:0] regSrc2;
	wire [15:0] regOut1;
	wire [15:0] regOut2;

	wire [5:0] aluOp;
	wire cFlag;
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

	reg [15:0] dataMem [127:0];
	reg [15:0] instMem [127:0];
	initial begin
		// Load in the program/initial memory state into the memory module
`ifdef FIBO
		$readmemh("fibo.hex", instMem);
`else
		$readmemh("test.hex", instMem);
`endif
	end

	always @(posedge clk) begin
		if (memWE) begin // When the WE line is asserted, write into memory at the given address
			dataMem[dAddr[9:0]] <= regOut2; // Limit the range of the addresses
		end
	end

	assign dDataOut = dataMem[dAddr[9:0]];
	assign instruction = instMem[PC[9:0]];

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
		.inReg(regDst),
		.dataIn(regDataIn),
		.outReg1(regSrc1),
		.outReg2(regSrc2),
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
		.regDataInSource(regDataInSource),
		.immData(immData),
		.regDst(regDst),
		.regFileWE(regFileWE),
		.regSrc1(regSrc1),
		.regSrc2(regSrc2),
		.aluOp(aluOp),
		.memWE(memWE),
		.dAddrSel(dAddrSel),
		.instrData(instrData)
	);

	// PC Logic
	always @(*) begin
		nextPC = 16'd0;

    case (nextPCSel)
		// From instruction absolute
		2'b01: begin
			nextPC = instrData;
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
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			PC <= 16'b0;
		end
		else begin
			PC <= nextPC;
		end
	end

	// Extra logic
	assign regDataIn = (immData) ? instrData : ((regDataInSource) ? dDataOut : aluOut);
	assign dAddr = (dAddrSel) ? regOut1 : instrData;

	assign led = PC[7:0];
endmodule
