module ALU(
	input clk, // Note we need a clock and reset for the Z register
	input rst,
	input [15:0] in1,
	input [15:0] in2,
	input op, // Adding more functions to the system means adding bits to this
	output reg [15:0] out,
	output reg zFlag
);

	reg zFlagNext;

	// Z flag register
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			zFlag <= 1'b0;
		end else begin
			zFlag <= zFlagNext;
		end
	end

	// ALU Logic
	always @(*) begin
		// Defaults -- I do this to: 1) make sure there are no latches, 2) list all
		// variables set by this block
		out = 16'd0;
		zFlagNext = zFlag; // Note, according to our ISA, the z flag only changes when an ADD is performed, otherwise it should retain its value

		case (op)
		// Note aluOp == 0 is not mapped to anything, it could be mapped to more
		// operations later, but for now theres no logic needed behind it
		// ADD
		1: begin
			out = in1 + in2;
			zFlagNext = (out == 16'd0);
		end
		endcase
	end
endmodule
