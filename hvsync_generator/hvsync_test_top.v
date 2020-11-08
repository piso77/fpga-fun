`timescale 1ns / 1ps

module hvsync_test_top(clk, hsync, vsync, rgb);

input clk;
output hsync, vsync;
output [2:0] rgb;
wire display_on;
wire [H_LEN:0] hpos;
wire [V_LEN:0] vpos;

wire pixclk;
pll pixclk_pll(
				.clock_in(clk),
				.clock_out(pixclk)
);

hvsync_generator hvsync_gen(
	.clk(pixclk),
	.reset(1'b0),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

wire r = display_on && (((hpos&7)==0) || ((vpos&7)==0));
wire g = display_on && vpos[4];
wire b = display_on && hpos[4];
assign rgb = {b,g,r};

endmodule
