module processor(
	input clk,
	input rst,
`ifdef DEBUG
	output [15:0] instruction,
	output [15:0] PC,
	output memWE,
	output regFileWE,
	output [15:0] memAddr,
	output [15:0] regDstData,
	output [15:0] regSrcData,
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

	wire [15:0] memAddr;
	wire [15:0] dDataOut;
	wire memWE;
	wire memAddrSelDst;
	wire memAddrSelSrc;

	wire [15:0] instrData;

	wire [15:0] regDataIn;
	wire [3:0] regDst;
	wire regFileWE;
	wire regDataInSource;
	wire immData;
	wire [3:0] regSrc;
	wire [15:0] regDstData;
	wire [15:0] regSrcData;

	wire [3:0] opcode;
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
			dataMem[memAddr[9:0]] <= regSrcData; // Limit the range of the addresses
		end
	end

	assign dDataOut = dataMem[memAddr[9:0]];
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
		.outReg1(regDst),
		.outReg2(regSrc),
		.dataOut1(regDstData),
		.dataOut2(regSrcData)
	);

	ALU alu(
		.clk(clk),
		.rst(rst),
		.op(opcode),
		.in1(regDstData),
		.in2(regSrcData),
		.out(aluOut),
		.cFlag(cFlag),
		.zFlag(zFlag)
	);

	decoder decode(
		.instruction(instruction),
		.opcode(opcode),
		.cFlag(cFlag),
		.zFlag(zFlag),
		.nextPCSel(nextPCSel),
		.regDataInSource(regDataInSource),
		.immData(immData),
		.regDst(regDst),
		.regFileWE(regFileWE),
		.regSrc(regSrc),
		.memWE(memWE),
		.memAddrSelDst(memAddrSelDst),
		.memAddrSelSrc(memAddrSelSrc),
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
			nextPC = regSrcData;
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
	assign memAddr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);

	assign led = PC[7:0];
endmodule
