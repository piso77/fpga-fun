`include "hvsync_generator/header.v"

module racing_game_top(clk, hsync, vsync, rgb, left, right, up, down, reset);
	input clk, reset;
	input left, right, up, down;
	output hsync, vsync;
	wire display_on;
	wire [9:0] hpos, vpos;
	output [2:0] rgb;

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

	parameter PADDLE_X = 0;	// paddle X coordinate
	parameter PADDLE_Y = 1;	// paddle Y coordinate
	parameter PLAYER_X = 2;	// player X coordinate
	parameter PLAYER_Y = 3;	// player Y coordinate
	parameter ENEMY_X = 4;	// enemy X coordinate
	parameter ENEMY_Y = 5;	// enemy Y coordinate
	parameter ENEMY_DIR = 6;	// enemy direction (1, -1)
	parameter SPEED = 7;		// player speed
	parameter TRACKPOS_LO = 8;	// track position (lo byte)
	parameter TRACKPOS_HI = 9;	// track position (hi byte)

	parameter IN_HPOS = 8'h40;	// CRT horizontal position
	parameter IN_VPOS = 8'h41;	// CRT vertical position
	// flags: [0, 0, collision, vsync, hsync, vpaddle, hpaddle, display_on]
	parameter IN_FLAGS = 8'h42;

	reg [7:0] ram[0:15];	// 16 bytes of RAM
	reg [7:0] rom[0:127];	// 128 bytes of ROM

	wire [7:0] address_bus;	// CPU address bus
	reg  [7:0] to_cpu;		// data bus to CPU
	wire [7:0] from_cpu;		// data bus from CPU
	wire write_enable;		// write enable bit from CPU

	// 8-bit CPU module
	CPU cpu(
		.clk(clk25mhz),
		.reset(reset),
		.address(address_bus),
		.data_in(to_cpu),
		.data_out(from_cpu),
		.write(write_enable)
	);

	initial
		$readmemh("racing8.hex", rom);

	// RAM write from CPU
	always @(posedge clk25mhz)
		if (write_enable)
			ram[address_bus[3:0]] <= from_cpu;

	wire hpaddle = (joy_x == vpos);
	wire vpaddle = (joy_y == vpos);

	// RAM read from CPU
	always @(*)
		casez (address_bus)
			// RAM
			8'b00??????: to_cpu = ram[address_bus[3:0]];

			// special read registers
			IN_HPOS:  to_cpu = hpos[7:0];
			IN_VPOS:  to_cpu = vpos[7:0];
			IN_FLAGS: to_cpu = {2'b0, frame_collision, vsync, hsync, vpaddle, hpaddle, display_on};

			// ROM
			8'b1???????: to_cpu = rom[address_bus[6:0]];

			default: to_cpu = 8'bxxxxxxxx;
		endcase

	hvsync_generator hvsync_gen(
		.clk(clk25mhz),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.display_on(display_on),
		.hpos(hpos),
		.vpos(vpos)
	);

	// joy position (set continuosly during frame)
	reg [9:0] joy_x = H_DISPLAY / 2;
	reg [9:0] joy_y = 16;

	always @(posedge clk100hz)
		if (left == 1'b1 && joy_x != 0)
			joy_x <= joy_x - 1;
		else if (right == 1'b1 && joy_x != H_DISPLAY-16)
			joy_x <= joy_x + 1;
		else if (up == 1'b1 && joy_y != 16)
			joy_y <= joy_y - 1;
		else if (down == 1'b1 && joy_y != 128)
			joy_y <= joy_y + 1;

	// flags for player sprite renderer module
	wire player_vstart = {1'b0,ram[PLAYER_Y]} == vpos;
	wire player_hstart = {1'b0,ram[PLAYER_X]} == hpos;
	wire player_gfx;
	wire player_is_drawing;

	// flags for enemy sprite renderer module
	wire enemy_vstart = {1'b0,ram[ENEMY_Y]} == vpos;
	wire enemy_hstart = {1'b0,ram[ENEMY_X]} == hpos;
	wire enemy_gfx;
	wire enemy_is_drawing;

	// select player or enemy access to ROM
	// multiplexing between player and enemy ROM address
	wire player_load = (hpos >= H_DISPLAY) && (hpos < H_DISPLAY+4);
	wire enemy_load = (hpos >= H_DISPLAY+4);
	wire [3:0] player_sprite_yofs;
	wire [3:0] enemy_sprite_yofs;
	wire [3:0] car_sprite_yofs = player_load ? player_sprite_yofs : enemy_sprite_yofs;
	wire [7:0] car_sprite_bits;
	car_bitmap car(
		.yofs(car_sprite_yofs),
		.bits(car_sprite_bits));

	sprite_renderer player_renderer(
		.clk(clk25mhz),
		.mirror(1),
		.vstart(player_vstart),
		.load(player_load),
		.hstart(player_hstart),
		.rom_addr(player_sprite_yofs),
		.rom_bits(car_sprite_bits),
		.gfx(player_gfx),
		.in_progress(player_is_drawing));

	sprite_renderer enemy_renderer(
		.clk(clk25mhz),
		.mirror(1),
		.vstart(enemy_vstart),
		.load(enemy_load),
		.hstart(enemy_hstart),
		.rom_addr(enemy_sprite_yofs),
		.rom_bits(car_sprite_bits),
		.gfx(enemy_gfx),
		.in_progress(enemy_is_drawing));

	// set to 1 when player collides with enemy or track
	reg frame_collision;
	always @(posedge clk25mhz)
		if (player_gfx && (enemy_gfx || track_gfx))
			frame_collision <= 1;
		else if (vsync)
			frame_collision <= 0;

	// track graphics signals
	wire track_offside = (hpos[9:6]==0) || (hpos[9:6]==9);		// offside < 64 || > 576
	wire track_shoulder = (hpos[9:3]==7) || (hpos[9:3]==72);	// shoulder 56-64 || 576-584
	wire track_gfx = (vpos[5:1]!=ram[TRACKPOS_LO]) && track_offside;

	// RGB output
	wire r = display_on && (player_gfx || enemy_gfx || track_shoulder);
	wire g = display_on && (player_gfx || track_gfx);
	wire b = display_on && (enemy_gfx || track_shoulder);
	assign rgb = {b,g,r};

endmodule
