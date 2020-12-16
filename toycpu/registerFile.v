module registerFile(
`ifdef DEBUG
	output [15:0] reg0,
	output [15:0] reg1,
	output [15:0] reg2,
	output [15:0] reg3,
`endif
	input clk,
	input rst,
	input we,
	input [3:0] regDst,
	input [3:0] regSrc,
	input [15:0] regDstDataIn,
	output [15:0] regDstDataOut,
	output [15:0] regSrcDataOut
);

	reg [15:0] regs[15:0];
	integer i;

	// Actual register file storage
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			for (i=0; i <16; i++) begin
				regs[i] <= 16'd0;
			end
		end else begin
			if (we) begin // Only write back when asserted, not all instructions write to the register file!
				regs[regDst] <= regDstDataIn;
			end
		end
	end

	// Output registers
	assign regDstDataOut = regs[regDst];
	assign regSrcDataOut = regs[regSrc];

`ifdef DEBUG
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;

	assign reg0 = regs[0];
	assign reg1 = regs[1];
	assign reg2 = regs[2];
	assign reg3 = regs[3];
`endif
endmodule
