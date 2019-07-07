`define VGADISPLAY

`ifndef HEADER_H
`define HEADER_H

`ifdef VGADISPLAY
// declarations for VGA 640x480@60hz sync parameters
// horizontal constants
parameter H_DISPLAY			= 640; // horizontal display width
parameter H_FRONT			=  16; // horizontal right border (front porch)
parameter H_SYNC			=  96; // horizontal sync width
parameter H_BACK			=  48; // horizontal left border (back porch)
// vertical constants
parameter V_DISPLAY			= 480; // vertical display height
parameter V_BOTTOM			=  10; // vertical bottom border
parameter V_SYNC			=   2; // vertical sync # lines
parameter V_TOP				=  33; // vertical top border
`else
// declarations for TV-simulator sync parameters
// horizontal constants
parameter H_DISPLAY			= 256; // horizontal display width
parameter H_BACK			=  23; // horizontal left border (back porch)
parameter H_FRONT			=   7; // horizontal right border (front porch)
parameter H_SYNC			=  23; // horizontal sync width
// vertical constants
parameter V_DISPLAY			= 240; // vertical display height
parameter V_TOP				=   5; // vertical top border
parameter V_BOTTOM			=  14; // vertical bottom border
parameter V_SYNC			=   3; // vertical sync # lines
`endif

// derived constants
parameter H_SYNC_START		= H_DISPLAY + H_FRONT;
parameter H_SYNC_END		= H_DISPLAY + H_FRONT + H_SYNC - 1;
parameter H_MAX				= H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;
parameter V_SYNC_START		= V_DISPLAY + V_BOTTOM;
parameter V_SYNC_END		= V_DISPLAY + V_BOTTOM + V_SYNC - 1;
parameter V_MAX				= V_DISPLAY + V_BOTTOM + V_SYNC + V_TOP - 1;

`endif
