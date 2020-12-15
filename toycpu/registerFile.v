module registerFile(
`ifdef DEBUG
	output [15:0] reg0,
	output [15:0] reg1,
	output [15:0] reg2,
	output [15:0] reg3,
`endif
	input clk,
	input rst,
	input we,								// Dont actually write back unless asserted
	input [3:0] inReg,			// Register number to write back to
	input [15:0] dataIn,		// Data for write back register
	input [3:0] outReg1,		// Register number for out1
	input [3:0] outReg2,		// Register number for out2
	output [15:0] dataOut1,
	output [15:0] dataOut2
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
				regs[inReg] <= dataIn;
			end
		end
	end

	// Output registers
	assign dataOut1 = regs[outReg1];
	assign dataOut2 = regs[outReg2];

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
