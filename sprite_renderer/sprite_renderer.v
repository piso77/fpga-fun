`ifndef SPRITE_RENDERER_H
`define SPRITE_RENDERER_H

`include "header.v"

/*
Display a 16x16 sprite (8 bits mirrored left / right)
*/

module sprite_renderer(clk, vstart, load, hstart, rom_addr, rom_bits, gfx,
						in_progress);

	input clk;
	input vstart;			// start drawing (top border)
	input load;				// ok to load sprite data?
	input hstart;			// start drawing scanline (left border)
	output [3:0] rom_addr;	// select ROM address
	input [7:0] rom_bits;	// input bits from ROM
	output gfx;				// output pixel
	output in_progress;		// 0 if waiting for vstart

endmodule

module sprite_renderer_top(clk, hsync, vsync, rgb left, right, up, down);

	input clk;
	input left, right, up, down;
	output hsync, vsync;
	output [2:0] rgb;
	wire display_on;
	wire [8:0] hpos, vpos;

endmodule

`endif
