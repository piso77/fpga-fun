`ifndef LFSR_V
`define LFSR_V

/*
Configurable Linear Feedback Shift Register
*/
module lfsr(clk, reset, enable, lfsr);
	parameter TAPS		= 8'b11101;		// bitmask for taps
	parameter INVERT	= 0;			// invert feedback bit?
	//localparam NBITS	= $size(TAPS);	// bit width
	localparam NBITS	= 8;

	input clk, reset;
	input enable;
	output reg [NBITS-1:0] lfsr;		// actual shift register

	wire feedback = lfsr[NBITS-1] ^ INVERT;

	always @(posedge clk)
	begin
		if (reset)
			lfsr = {lfsr[NBITS-2:0], 1'b1};	// reset loads with all 1s
		else if (enable)
			lfsr = {lfsr[NBITS-2:0], 1'b0} ^ (feedback ? TAPS : 0);
	end
endmodule

`endif
