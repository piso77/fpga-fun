`timescale 1ns / 1ps

`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

`include "header.v"

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
output reg [H_LEN:0] hpos;
output reg [V_LEN:0] vpos;

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
