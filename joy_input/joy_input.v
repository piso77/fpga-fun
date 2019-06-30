/*
4 way joystick input demonstration
*/

`include "header.v"

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

module joy_input_top(clk, reset, hsync, vsync, rgb, left, right, up, down);

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

	// player position (only set at VSYNC)
	reg [9:0] player_x;
	reg [9:0] player_y;

	// joy position (set continuosly during frame)
	reg [9:0] joy_x = 320;
	reg [9:0] joy_y = 240;

	always @(posedge clk100hz)
		if (left == 1'b1 && joy_x != 0)
			joy_x <= joy_x - 1;
		else if (right == 1'b1 && joy_x != H_DISPLAY)
			joy_x <= joy_x + 1;
		else if (up == 1'b1 && joy_y != 0)
			joy_y <= joy_y - 1;
		else if (down == 1'b1 && joy_y != V_DISPLAY)
			joy_y <= joy_y + 1;

	always @(posedge vsync)
		begin
			player_x <= joy_x;
			player_y <= joy_y;
		end

	// display joy position on screen
	wire h = hpos[9:0] >= joy_x;
	wire v = vpos[9:0] >= joy_y;

	assign rgb = {1'b0, display_on && h, display_on && v};

endmodule
