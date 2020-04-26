`timescale 1ns / 1ps

`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
 * Video sync generatorm used to drive a simulated CRT.
 * To use:
 * - wire hsync and vsync to top levele outputs
 * - add a 3bit (or more) "rgb" output to the top level
 */
 
module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);

input clk;
input reset;
output reg hsync;
output reg vsync;
output display_on;
output reg [9:0] hpos;
output reg [9:0] vpos;

`define VGADISPLAY
`ifdef VGADISPLAY
// declarations for VGA 640x480@60hz sync parameters
// horizontal constants
parameter H_DISPLAY			= 640; // horizontal display width
parameter H_FRONT				=  16; // horizontal right border (front porch)
parameter H_SYNC				=  96; // horizontal sync width
parameter H_BACK				=  48; // horizontal left border (back porch)
// vertical constants
parameter V_DISPLAY			= 480; // vertical display height
parameter V_BOTTOM			=  10; // vertical bottom border - 11?
parameter V_SYNC				=   2; // vertical sync # lines
parameter V_TOP				=  33; // vertical top border - 31?
`else
// declarations for TV-simulator sync parameters
// horizontal constants
parameter H_DISPLAY			= 256; // horizontal display width
parameter H_BACK				=  23; // horizontal left border (back porch)
parameter H_FRONT				=   7; // horizontal right border (front porch)
parameter H_SYNC				=  23; // horizontal sync width
// vertical constants
parameter V_DISPLAY			= 240; // vertical display height
parameter V_TOP				=   5; // vertical top border
parameter V_BOTTOM			=  14; // vertical bottom border
parameter V_SYNC				=   3; // vertical sync # lines
`endif

// derived constants
parameter H_SYNC_START		= H_DISPLAY + H_FRONT;
parameter H_SYNC_END			= H_DISPLAY + H_FRONT + H_SYNC - 1;
parameter H_MAX				= H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
parameter V_SYNC_START		= V_DISPLAY + V_BOTTOM;
parameter V_SYNC_END			= V_DISPLAY + V_BOTTOM + V_SYNC - 1;
parameter V_MAX				= V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

wire hmaxxed = (hpos == H_MAX) || reset; // set when hpos is maximum
wire vmaxxed = (vpos == V_MAX) || reset; // set when vpos is maximum

// horizontal position counter
always @(posedge clk)
begin
  hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
  if (hmaxxed)
    hpos <= 0;
  else
    hpos <= hpos + 1'b1;
end

// vertical position counter
always @(posedge clk)
begin
  vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
  if (hmaxxed)
    if (vmaxxed)
      vpos <= 0;
	 else
      vpos <= vpos + 1'b1;
end

// display_on is set when beam is in "safe" visible frame
assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule
`endif