`timescale 1ns / 1ps

module hvsync_test_top(clk, hsync, vsync, rgb);

input clk;
output hsync, vsync;
output [2:0] rgb;
wire display_on;
wire [8:0] hpos;
wire [8:0] vpos;

wire clk5;

hvsync_generator hvsync_gen(
	.clk(clk5),
	.reset(1'b0),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

clk_wiz_v3_6 clk_generator_mhz(
	.clk_in1(clk),
	.clk_out1(clk5)
);

wire r = display_on && (((hpos&7)==0) || ((vpos&7)==0));
wire g = display_on && vpos[4];
wire b = display_on && hpos[4];
assign rgb = {b,g,r};

endmodule
