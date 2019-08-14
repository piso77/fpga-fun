/* Scrolling starfield generator using a period (2^16-1) LFSR. */

module startfield_top(clk, reset, hsync, vsync, rgb);
	input clk, reset;
	output hsync, vsync;
	output [2:0] rgb;
	wire display_on;
	wire [9:0] hpos, vpos;
	wire [15:0] lfsr;

	wire clk25;

	`ifdef XILINX
	clk_wiz_v3_6 clk_pll_25(
		.clk_in1(clk),
		.clk_out1(clk25)
	);
	`else
	pll clk_pll_25(
		.clock_in(clk),
		.clock_out(clk25),
		.locked()
	);
	`endif

	hvsync_generator hvsync_gen(
		.clk(clk25),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.display_on(display_on),
		.hpos(hpos),
		.vpos(vpos)
	);

	// enable LFSR only in 256x256 aread
	wire start_enable  = !hpos[8] & !vpos[8];

	// LFSR with period = 2^16-1 = 256*256-1
	LFSR #(16'b1000000001011,0,16) lfsr_gen(
		.clk(clk25),
		.reset(reset),
		.enable(start_enable),
		.lfsr(lfsr)
	);

	wire star_on = &lfsr[15:9]; // all 7 bits must be set
	assign rgb = display_on && star_on ? lfsr[2:0] : 0;
endmodule
