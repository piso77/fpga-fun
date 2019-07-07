module racing_game_top(clk, hsync, vsync, rgb, left, right, up, down, reset);
	input clk, reset;
	input left, right, up, down;
	output hsync, vsync;
	output [2:0] rgb;
	wire display_on;
	wire [9:0] hpos, vpos;

	wire clk25mhz, clk100hz;

	`ifdef XILINX
	clk_wiz_v3_6 clk_pll_25(
		.clk_in1(clk),
		.clk_out1(clk25mhz)
	);
	`else
	pll clk_pll_25(
		.clock_in(clk),
		.clock_out(clk25mhz),
		.locked()
	);
	`endif

	clk_div_100hz clkdiv100hz(
		.clk(clk25mhz),
		.reset(reset),
		.clkout(clk100hz)
	);

	hvsync_generator hvsync_gen(
		.clk(clk25mhz),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.display_on(display_on),
		.hpos(hpos),
		.vpos(vpos)
	);

endmodule
