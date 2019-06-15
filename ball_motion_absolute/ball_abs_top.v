`timescale 1ns / 1ps

module ball_abs_top(clk, stop, res, hsync, vsync, rgb);

input clk, res, stop;
output hsync, vsync;
output [2:0] rgb;

localparam BALL_SIZE		= 4;				// ball size (in pixels)
localparam ball_h_initial	= 320 - BALL_SIZE;	// ball initial X position
localparam ball_v_initial	= 240 - BALL_SIZE;	// ball initial Y position

reg [9:0] ball_hpos = ball_h_initial;			// ball current X, Y position
reg [9:0] ball_vpos = ball_v_initial;
reg [9:0] ball_h_mov = 2;						// ball current X, Y velocity
reg [9:0] ball_v_mov = 2;

wire clk25;
wire display_on;
wire [9:0] hpos, vpos;
wire reset;

assign reset = ~res;

`ifdef XILINX
clk_wiz_v3_6 clk_wiz_25(
        .clk_in1(clk),
        .clk_out1(clk25)
);
`else
`endif

// video sync generator
  hvsync_generator hvsync_gen(
    .clk(clk25),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
);

//`define NONBLOCKING

// update ball position
`ifdef NONBLOCKING
always @(posedge vsync or posedge reset)
begin
	if (reset) begin
		// reset ball position
		ball_hpos <= ball_h_initial;
		ball_vpos <= ball_v_initial;
	end else begin
		if (!stop) begin
			// add velocity vector to ball position
			ball_hpos <= ball_hpos + ball_h_mov;
			ball_vpos <= ball_vpos + ball_v_mov;
		end
	end
end


// collision with h and v boundaries (e.g. touch a border)
wire ball_h_collide = ball_hpos >= (640 - BALL_SIZE);
wire ball_v_collide = ball_vpos >= (480 - BALL_SIZE);

// bounces
always @(posedge ball_h_collide)
begin
	ball_h_mov <= -ball_h_mov;
end

always @(posedge ball_v_collide)
begin
	ball_v_mov <= -ball_v_mov;
end

`else // BLOCKING - default behaviour

always @(posedge vsync or posedge reset)
begin
	if (reset) begin
		// reset ball position
		ball_hpos = ball_h_initial;
		ball_vpos = ball_v_initial;
	end else begin
		if (!stop) begin
			// add velocity vector to ball position
			ball_hpos = ball_hpos + ball_h_mov;
			ball_vpos = ball_vpos + ball_v_mov;
			if (ball_hpos <= BALL_SIZE || ball_hpos >= (640 - BALL_SIZE)) begin
				ball_h_mov = -ball_h_mov;
			end
			if (ball_vpos <= BALL_SIZE || ball_vpos >= (480 - BALL_SIZE)) begin
				ball_v_mov = -ball_v_mov;
			end
		end
	end
end
`endif
// end of update ball position


// output graphics block
// offset of ball position from video beam
wire [9:0] ball_hdiff = hpos - ball_hpos;
wire [9:0] ball_vdiff = vpos - ball_vpos;

// ball graphics output
wire ball_hgfx = ball_hdiff < BALL_SIZE;
wire ball_vgfx = ball_vdiff < BALL_SIZE;
wire ball_gfx = ball_hgfx && ball_vgfx;

// combine signals to RGB output
wire grid_gfx = (((hpos&7)==0) && ((vpos&7)==0));
wire bordh_coll = hpos == 0 || hpos == 639;
wire bordv_coll = vpos == 0 || vpos == 479;
wire r = display_on && (ball_hgfx | ball_gfx);
wire g = display_on && (grid_gfx | ball_gfx | bordh_coll | bordv_coll);
wire b = display_on && (ball_vgfx | ball_gfx);
assign rgb = {b,g,r};

endmodule
