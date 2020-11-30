module ALU(
	input clk, // Note we need a clock and reset for the Z register
	input rst,
	input [6:0] op,
	input [15:0] in1,
	input [15:0] in2,
	output [15:0] out,
	output reg cFlag,
	output reg zFlag
);

	reg cFlagNext, zFlagNext;
	reg [16:0] tmpout;

	// Z flag register
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			cFlag <= 1'b0;
			zFlag <= 1'b0;
		end else begin
			cFlag <= cFlagNext;
			zFlag <= zFlagNext;
		end
	end

	assign out = tmpout[15:0];

	// ALU Logic
	always @(*) begin
		// Defaults -- I do this to: 1) make sure there are no latches, 2) list all
		// variables set by this block
		tmpout = 17'd0;
	 // Note, according to our ISA, the z flag only changes when an ADD is performed, otherwise it should retain its value
		cFlagNext = cFlag;
		zFlagNext = zFlag;

		case (op)
		// MV
		0: begin
			tmpout = {1'b0, in1};
		end
		// ADD
		1: begin
			tmpout = in1 + in2;
			zFlagNext = (tmpout == 17'b0);
			cFlagNext = (tmpout[16] == 1'b1);
		end
		endcase
	end
endmodule
