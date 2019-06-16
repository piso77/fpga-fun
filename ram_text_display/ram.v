`ifndef RAM_H
`define RAM_H

/*
Module parameters:

D - memory depth (default = 10)
W - memory width (default = 8)
*/

module ram_sync(clk, addr, din, dout, we);

	parameter D = 10; // # of address bits
	parameter W = 8;  // # of data bits

	input clk, we;
	input [D-1:0] addr;
	input [W-1:0] din;
	output reg [W-1:0] dout;

	reg [W-1:0] ram[0:(1<<D)-1]; // (1<<D)xW bit memory

	always @(posedge clk) begin
		if (we) begin
			ram[addr] <= din;
		end
		dout <= ram[addr];
	end

endmodule


`endif
