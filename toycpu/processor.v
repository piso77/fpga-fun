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

	wire [15:0] instruction;

	wire memWE;
	wire [15:0] memAddr;
	wire [15:0] memData;

	wire regFileWE;
	wire [3:0] regDst;
	wire [15:0] regDstDataIn;
	wire [15:0] regDstData;
	wire [3:0] regSrc;
	wire [15:0] regSrcData;

	wire [15:0] aluOut;
	wire cFlag;
	wire zFlag;

	wire [3:0] opcode;
	wire memAddrSelDst;
	wire memAddrSelSrc;
	wire regDataInSource;
	wire immData;
	wire [15:0] instrData;

	wire [1:0] nextPCSel;
	reg [15:0] PC;
	reg [15:0] nextPC;

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

	assign memData = dataMem[memAddr[9:0]];
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
		.regDst(regDst),
		.regDstDataOut(regDstData),
		.regDstDataIn(regDstDataIn),
		.regSrc(regSrc),
		.regSrcDataOut(regSrcData)
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
	assign regDstDataIn = (immData) ? instrData : ((regDataInSource) ? memData : aluOut);
	assign memAddr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);

	assign led = PC[7:0];
endmodule
