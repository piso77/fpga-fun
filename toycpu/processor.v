module processor(
`ifdef DEBUG
	output reg_we,
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
	output [15:0] addr_bus,
	input [15:0] data_in,
	output [15:0] data_out,
	output mem_we,
	input [15:0] mem_data_in
);

	wire reg_we;
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
	wire mem_bus_sel;
	wire immMode;
	wire indMode;
	wire [15:0] instrData;

	wire [1:0] nextPCSel;
	reg [15:0] nextPC;
	reg [15:0] pc_addr;

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
		.we(reg_we),
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
		.ce(de_ce),
		.opcode(opcode),
		.cFlag(cFlag),
		.zFlag(zFlag),
		.nextPCSel(nextPCSel),
		.immMode(immMode),
		.indMode(indMode),
		.regDst(regDst),
		.regFileWE(reg_we),
		.regSrc(regSrc),
		.memWE(mem_we),
		.memAddrSelDst(memAddrSelDst),
		.memAddrSelSrc(memAddrSelSrc),
		.mem_bus_sel(mem_bus_sel),
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
			nextPC = pc_addr + 16'd1;
		end
		endcase
	end

	localparam [1:0]
    S_FETCH = 2'b01,
		S_EXEC  = 2'b10,
    S_WBACK = 2'b11;
	reg [1:0] state;
	reg [15:0] instruction;
	reg de_ce;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			pc_addr <= 16'b0;
			de_ce <= 1'b0;
			state <= S_FETCH;
		end else begin
			de_ce <= 1'b0;
			case (state)
				S_FETCH: begin
					instruction <= data_in;
					de_ce <= 1'b1;
					state <= S_EXEC;
				end
				S_EXEC: begin
					pc_addr <= nextPC;
					state <= S_FETCH;
				end
				S_WBACK: begin
					pc_addr <= nextPC;
					state <= S_FETCH;
				end
			endcase
		end
	end

	// Extra logic
	wire [15:0] mem_addr;
	assign addr_bus = (mem_bus_sel) ? mem_addr : pc_addr;
	assign data_out = regSrcData;
	assign mem_addr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);
	assign regDstDataIn = (immMode) ? instrData : ((indMode) ? mem_data_in : aluOut);
endmodule

module processor_top(
`ifdef DEBUG
	output [15:0] addr_bus,
	output [15:0] data_in,
	output mem_we,
	output reg_we,
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
`endif
	assign data_in = memory[addr_bus[7:0]];

	wire [15:0] data_out;
	wire [15:0] mem_data;
	always @(posedge clk) begin
		if (mem_we) begin // When the WE line is asserted, write into memory at the given address
			memory[addr_bus[7:0]] <= data_out; // Limit the range of the addresses
		end
	end

	assign mem_data = memory[addr_bus[7:0]];

	processor cpu(
`ifdef DEBUG
		.reg_we(reg_we),
		.regDstData(regDstData),
		.regSrcData(regSrcData),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag),
`endif
		.addr_bus(addr_bus),
		.data_in(data_in),
		.data_out(data_out),
		.clk(clk),
		.rst(rst),
		.mem_we(mem_we),
		.mem_data_in(mem_data)
	);
endmodule
