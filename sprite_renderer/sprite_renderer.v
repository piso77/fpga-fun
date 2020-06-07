`ifndef SPRITE_RENDERER_H
`define SPRITE_RENDERER_H

`include "hvsync_generator/header.v"

module clk_div_100hz(clk, reset, clkout);

	input clk, reset;
	output reg clkout;

	// 100MHz * cntEndVal = 5Hz
	//parameter cntEndVal = 24'h989680;
	// 25MHz * cntEndVal = 5Hz
	//parameter cntEndVal = 24'h2625A0;
	// 25MHz * cntEndVal = 50Hz
	//parameter cntEndVal = 24'h3D090;
	// 25MHz * cntEndVal = 100Hz
	parameter cntEndVal = 24'h1E848;
	reg [23:0] clk_cnt = 24'h000000;

	always @(posedge clk) begin
		if (reset == 1'b1) begin
			clkout <= 1'b0;
			clk_cnt <= 24'h000000;
		end
		else begin
			if (clk_cnt == cntEndVal) begin
				clkout <= ~clkout;
				clk_cnt <= 24'h000000;
			end
			else begin
				clk_cnt <= clk_cnt + 1'b1;
			end
		end
	end

endmodule

/*
Display a 16x16 sprite (8 bits mirrored left / right)
*/

module sprite_renderer(clk, vstart, load, hstart, rom_addr, rom_bits, gfx,
						in_progress);

	input clk;
	input vstart;			// start drawing (reached top border)
	input load;				// ok to load sprite data? (reached hsync area)
	input hstart;			// start drawing scanline (reached left border)
	output reg [3:0] rom_addr;	// select ROM address
	input [7:0] rom_bits;	// input bits from ROM
	output reg gfx;				// output pixel
	output in_progress;		// 0 if waiting for vstart

	reg [2:0] state;		// FSM state
	reg [3:0] ycount;		// sprite's scanlines drawn so far
	reg [3:0] xcount;		// sprite's horiz. pixels drawn so far

	reg [7:0] outbits;		// latch sprite bits from ROM

	// FSM states
	localparam WAIT_FOR_VSTART	= 0;
	localparam WAIT_FOR_LOAD	= 1;
	localparam LOAD_SETUP		= 2;
	localparam LOAD_FETCH		= 3;
	localparam WAIT_FOR_HSTART	= 4;
	localparam DRAW				= 5;

	assign in_progress = state != WAIT_FOR_VSTART;

	always @(posedge clk)
	begin
		case (state)
			WAIT_FOR_VSTART: begin
				ycount <= 1'b0;			// init vertical count
				gfx <= 1'b0;				// turn off pixel out
				if (vstart)
					state <= WAIT_FOR_LOAD;
			end
			WAIT_FOR_LOAD: begin
				xcount <= 1'b0;			// init horiz. count
				gfx <= 1'b0;
				if (load)
					state <= LOAD_SETUP;
			end
			LOAD_SETUP: begin
				rom_addr <= ycount;		// load ROM address
				state <= LOAD_FETCH;
			end
			LOAD_FETCH: begin
				outbits <= rom_bits;	// latch bits from ROM
				state <= WAIT_FOR_HSTART;
			end
			WAIT_FOR_HSTART: begin
				if (hstart)
					state <= DRAW;
			end
			DRAW: begin
				// get pixel, and mirror graphics left/right
				gfx <= outbits[xcount < 8 ? xcount[2:0] : ~xcount[2:0]];
				xcount <= xcount + 1;
				// finished drawing horizontal slice?
				if (xcount == 15) begin
					ycount <= ycount + 1;
					// finished drawing sprite?
					if (ycount == 15) // pre-increment value
						state <= WAIT_FOR_VSTART;	// done drawing sprite
					else
						state <= WAIT_FOR_LOAD;		// done drawing scanline
				end
			end
			// unknown state -- reset
			default: begin
				state <= WAIT_FOR_VSTART;
			end
		endcase
	end

endmodule

module sprite_renderer_top(clk, hsync, vsync, rgb, left, right, up, down, reset, led);

	input clk, reset;
	input left, right, up, down;
	output hsync, vsync;
	output [2:0] rgb;
	output [3:0] led;
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

	// player position (only set at VSYNC)
	reg [9:0] player_x;
	reg [9:0] player_y;

	// joy position (set continuosly during frame)
	reg [9:0] joy_x = H_DISPLAY / 2;
	reg [9:0] joy_y = V_DISPLAY / 2;

	always @(posedge clk100hz)
		if (left == 1'b1 && joy_x != 0)
			joy_x <= joy_x - 1;
		else if (right == 1'b1 && joy_x != H_DISPLAY-16)
			joy_x <= joy_x + 1;
		else if (up == 1'b1 && joy_y != 0)
			joy_y <= joy_y - 1;
		else if (down == 1'b1 && joy_y != V_DISPLAY-16)
			joy_y <= joy_y + 1;

	assign led = {up, down, left, right};

	always @(posedge vsync)
		begin
			player_x <= joy_x;
			player_y <= joy_y;
		end

	// car bitbamp ROM and wiring
	wire [3:0] car_sprite_addr;
	wire [7:0] car_sprite_bits;

	car_bitmap car(
		.yofs(car_sprite_addr),
		.bits(car_sprite_bits));

	// compare player X/Y to CRT hpos/vpos
	wire hstart = player_x == hpos;
	wire vstart = player_y == vpos;

	wire car_gfx;			// car sprite video signal
	wire in_progress;		// 1 = rendering taking place

	sprite_renderer renderer(
		.clk(clk25mhz),
		.vstart(vstart),
		.load(hsync),
		.hstart(hstart),
		.rom_addr(car_sprite_addr),
		.rom_bits(car_sprite_bits),
		.gfx(car_gfx),
		.in_progress(in_progress));

	// video RGB output
	wire r = display_on && car_gfx;
	wire g = display_on && car_gfx;
	wire b = display_on && in_progress;
	assign rgb = {b,g,r};

endmodule

`endif
