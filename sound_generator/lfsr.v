`ifndef LFSR_V
`define LFSR_V

/*
Configurable Linear Feedback Shift Register
*/
module LFSR(clk, reset, enable, lfsr);
	parameter TAPS		= 8'b11101;		// bitmask for taps
	parameter INVERT	= 0;			// invert feedback bit?
	//localparam NBITS	= $size(TAPS);	// bit width
	parameter NBITS		= 16;

	input clk, reset;
	input enable;
	output reg [NBITS-1:0] lfsr;		// actual shift register

	wire feedback = lfsr[NBITS-1] ^ INVERT;

	always @(posedge clk)
	begin
		if (reset) // XXX - reset period >= NBITS or undefined
			lfsr <= {lfsr[NBITS-2:0], 1'b1}; // fill reg with 1s from LSB
		else if (enable)
			lfsr <= {lfsr[NBITS-2:0], 1'b0} ^ (feedback ? TAPS : 0);
	end
endmodule

`endif
