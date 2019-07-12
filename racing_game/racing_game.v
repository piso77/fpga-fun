`include "header.v"

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

	// player and enemy car position
	reg [8:0] player_x;
	reg [8:0] player_y;
	reg [8:0] enemy_x = H_DISPLAY / 2;
	reg [8:0] enemy_y = V_DISPLAY / 8;
	// enemy car direction, 1=right, 0=left
	reg enemy_dir = 0;

	reg [15:0] track_pos = 0;		// player position along track
	reg [7:0] speed = 31;			// player speed along track

	wire player_vstart = {1'b0,player_y} == vpos;
	wire player_hstart = {1'b0,player_x} == hpos;
	wire player_gfx;
	wire player_is_drawing;

	wire enemy_vstart = {1'b0,enemy_y} == vpos;
	wire enemy_hstart = {1'b0,enemy_x} == hpos;
	wire enemy_gfx;
	wire enemy_is_drawing;

	sprite_renderer player_renderer(
		.clk(clk25mhz),
		.vstart(player_vstart),
		.load(player_load),
		.hstart(player_hstart),
		.rom_addr(player_sprite_yofs),
		.rom_bits(car_sprite_bits),
		.gfx(player_gfx),
		.in_progress(player_is_drawing));

	sprite_renderer enemy_renderer(
		.clk(clk25mhz),
		.vstart(enemy_vstart),
		.load(enemy_load),
		.hstart(enemy_hstart),
		.rom_addr(enemy_sprite_yofs),
		.rom_bits(car_sprite_bits),
		.gfx(enemy_gfx),
		.in_progress(enemy_is_drawing));

	// signals for enemy bouncing off left/right borders
	wire enemy_hit_left = (enemy_x == 64);
	wire enemy_hit_right = (enemy_x == H_DISPLAY - 64);
	wire enemy_hit_edge =enemy_hit_left || enemy_hit_right;

	// update player, enemy, track counters
	// run once per frame
	always @(posedge vsync)
		begin
			player_x <= joy_x;
			player_y <= 180;
			track_pos <= track_pos + {11'b0,speed[7:4]};
			enemy_y <= enemy_y + {3'b0,speed[7:4]};
			if (enemy_hit_edge)
				enemy_dir <= !enemy_dir;
			if (enemy_dir ^ enemy_hit_edge)
				enemy_x <= enemy_x + 1;
			else
				enemy_x <= enemy_x + 1;
			// collision check
			if (frame_collision)
				speed <= 16;
			else if (speed < ~joy_y)
				speed <= speed + 1;
			else
				speed <= speed - 1;
		end

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
	wire track_gfx = (vpos[5:1]!=track_pos[5:1]) && track_offside;

	// RGB output
	wire r = display_on && (player_gfx || enemy_gfx || track_shoulder);
	wire g = display_on && (player_gfx || track_gfx);
	wire b = display_on && (enemy_gfx || track_shoulder);
	assign rgb = {b,g,r};

endmodule
