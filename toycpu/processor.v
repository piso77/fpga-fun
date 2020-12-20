module processor(
`ifdef DEBUG
	output regFileWE,
	output [15:0] regDstData,
	output [15:0] reg0,
	output [15:0] reg1,
	output [15:0] reg2,
	output [15:0] reg3,
	output cFlag,
	output zFlag,
`endif
	input clk,
	input rst,
	output reg [15:0] addr_bus,
	input [15:0] data_in,
	output mem_we,
	input [15:0] mem_data_in,
	output [15:0] regSrcData
);

	wire regFileWE;
	wire [3:0] regDst;
	wire [15:0] regDstDataIn;
	wire [15:0] regDstData;
	wire [3:0] regSrc;

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
		.immMode(immMode),
		.indMode(indMode),
		.regDst(regDst),
		.regFileWE(regFileWE),
		.regSrc(regSrc),
		.memWE(mem_we),
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
			nextPC = addr_bus + 16'd1;
		end
		endcase
	end

	localparam [1:0]
    S_FETCH = 2'b01,
		S_EXEC  = 2'b10,
    S_WBACK = 2'b11;
	reg [1:0] state;
	reg [15:0] instruction;
	reg [15:0] data_out;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			addr_bus <= 16'b0;
			state <= S_FETCH;
		end else begin
			case (state)
				S_FETCH: begin
					instruction <= data_in;
					state <= S_EXEC;
				end
				S_EXEC: begin
					if (mem_we) begin
						addr_bus <= mem_addr;
						data_out <= regSrcData;
						state <= S_WBACK;
					end else begin
						addr_bus <= nextPC;
						state <= S_FETCH;
					end
				end
				S_WBACK: begin
					addr_bus <= nextPC;
					state <= S_FETCH;
				end
			endcase
		end
	end

	// Extra logic
	wire [15:0] mem_addr;
	assign mem_addr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);
	assign regDstDataIn = (immMode) ? instrData : ((indMode) ? mem_data_in : aluOut);
endmodule

module processor_top(
`ifdef DEBUG
	output [15:0] addr_bus,
	output [15:0] data_in,
	output mem_we,
	output regFileWE,
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

	reg [15:0] memory [255:0];
	initial begin
		// Load in the program/initial memory state into the memory module
`ifdef FIBO
		$readmemh("fibo.hex", memory);
`else
		$readmemh("test.hex", memory);
`endif
	end

`ifndef DEBUG
	wire [15:0] addr_bus;
	wire [15:0] data_in;
	wire mem_we;
	wire [15:0] regSrcData;
`endif
	assign data_in = memory[addr_bus[7:0]];

	wire [15:0] mem_data;
	always @(posedge clk) begin
		if (mem_we) begin // When the WE line is asserted, write into memory at the given address
			memory[addr_bus[7:0]] <= regSrcData; // Limit the range of the addresses
		end
	end

	assign mem_data = memory[addr_bus[7:0]];

	processor cpu(
`ifdef DEBUG
		.regFileWE(regFileWE),
		.regDstData(regDstData),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag),
`endif
		.addr_bus(addr_bus),
		.data_in(data_in),
		.clk(clk),
		.rst(rst),
		.mem_we(mem_we),
		.mem_data_in(mem_data),
		.regSrcData(regSrcData)
	);
endmodule
