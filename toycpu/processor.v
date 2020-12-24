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
	output mem_we
);

	wire reg_we;
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

	reg [15:0] instruction;
	reg decoder_ce;

	decoder decode(
		.instruction(instruction),
		.ce(decoder_ce),
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

	localparam
    S_FEXEC = 1'b0,
		S_WBACK = 1'b1;
	reg state;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			pc_addr <= 16'b0;
			decoder_ce <= 1'b0;
			state <= S_FEXEC;
		end else begin
			decoder_ce <= 1'b0;
			case (state)
				S_FEXEC: begin
					instruction <= data_in;
					decoder_ce <= 1'b1;
					state <= S_WBACK;
				end
				S_WBACK: begin
					pc_addr <= nextPC;
					state <= S_FEXEC;
				end
			endcase
		end
	end

	// Extra logic
	wire [15:0] mem_addr;
	assign addr_bus = (mem_bus_sel) ? mem_addr : pc_addr;
	assign data_out = regSrcData;
	assign mem_addr = (memAddrSelDst) ? regDstData : ((memAddrSelSrc) ? regSrcData : instrData);
	assign regDstDataIn = (immMode) ? instrData : ((indMode) ? data_in : aluOut);
endmodule

`ifndef DEBUG
module processor_top(
	input clk,
	input rst,
	input [7:0] sw,
	output reg [7:0] led
);

	reg [15:0] memory [127:0];
	initial begin
		// Load in the program/initial memory state into the memory module
		$readmemh("main.hex", memory);
	end

	wire [15:0] addr_bus;
	reg [15:0] data_in;
	always @(*)
		casez (addr_bus)
			// switches
			8'b1???????: data_in <= {8'b0, sw};
			// RAM
			default: data_in <= memory[addr_bus[7:0]];
		endcase

	wire mem_we;
	wire [15:0] data_out;
	always @(posedge clk) begin
		if (mem_we) begin
			casez (addr_bus)
				// leds
				8'b1???????: led <= data_out[7:0];
				// RAM
				default: memory[addr_bus[7:0]] <= data_out; // Limit the range of the addresses
			endcase
		end
	end

	processor cpu(
		.clk(clk),
		.rst(rst),
		.addr_bus(addr_bus),
		.data_in(data_in),
		.mem_we(mem_we),
		.data_out(data_out)
	);
endmodule
`endif
