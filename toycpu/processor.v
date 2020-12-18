module processor(
`ifdef DEBUG
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
	output zFlag,
`endif
	input clk,
	input rst,
	output reg [15:0] instr_addr,
	input [15:0] instr_data
);


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
	wire immMode;
	wire indMode;
	wire [15:0] instrData;

	wire [1:0] nextPCSel;
	reg [15:0] nextPC;

`ifdef DEBUG
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;
`endif

	reg [15:0] dataMem [127:0];
	always @(posedge clk) begin
		if (memWE) begin // When the WE line is asserted, write into memory at the given address
			dataMem[memAddr[9:0]] <= regSrcData; // Limit the range of the addresses
		end
	end

	assign memData = dataMem[memAddr[9:0]];

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
		.instruction(instr_data),
		.opcode(opcode),
		.cFlag(cFlag),
		.zFlag(zFlag),
		.nextPCSel(nextPCSel),
		.immMode(immMode),
		.indMode(indMode),
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
			nextPC = instr_addr + 16'd1;
		end
		endcase
	end

	// PC Register
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			instr_addr <= 16'b0;
		end
		else begin
			instr_addr <= nextPC;
		end
	end

	// Extra logic
	assign memAddr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);
	assign regDstDataIn = (immMode) ? instrData : ((indMode) ? memData : aluOut);
endmodule

module processor_top(
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
	output zFlag,
`endif
	input clk,
	input rst
);

	reg [15:0] instMem [127:0];
	initial begin
		// Load in the program/initial memory state into the memory module
`ifdef FIBO
		$readmemh("fibo.hex", instMem);
`else
		$readmemh("test.hex", instMem);
`endif
	end

	wire [15:0] PC;
	wire [15:0] instruction;
	assign instruction = instMem[PC[9:0]];

	processor cpu(
`ifdef DEBUG
		.memWE(memWE),
		.regFileWE(regFileWE),
		.memAddr(memAddr),
		.regDstData(regDstData),
		.regSrcData(regSrcData),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag),
`endif
		.instr_addr(PC),
		.instr_data(instruction),
		.clk(clk),
		.rst(rst)
	);
endmodule
