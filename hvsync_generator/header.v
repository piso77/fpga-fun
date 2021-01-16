`define VGA320X240

`ifndef HEADER_H
`define HEADER_H

`ifdef VGA1024X768
// XGA 1024x768@60hz - http://tinyvga.com/vga-timing/1024x768@60Hz
// Pixel freq.	65.0 MHz
parameter PIXELCLK		=   65;
parameter H_DISPLAY		= 1024;
parameter H_FRONT			=   24;
parameter H_SYNC			=  136;
parameter H_BACK			=  160;

parameter V_DISPLAY		=  768;
parameter V_BOTTOM		=    3;
parameter V_SYNC			=    6;
parameter V_TOP				=   29;

`elsif VGA640X480
// VGA 640x480@60hz - http://www.tinyvga.com/vga-timing/640x480@60Hz
// Pixel freq.	25.175 MHz
parameter PIXELCLK		=  25;
parameter H_DISPLAY		= 640;
parameter H_FRONT			=  16;
parameter H_SYNC			=  96;
parameter H_BACK			=  48;

parameter V_DISPLAY		= 480;
parameter V_BOTTOM		=  10;
parameter V_SYNC			=   2;
parameter V_TOP				=  33;

`elsif VGA320X240
// declarations for TV-simulator sync parameters
parameter PIXELCLK		= 60;  // PLL doesn't go down to 6Mhz so we first use
														 // the PLL to go down to 60Mhz, and then we apply
														 // an internal 1/10 clk divider
parameter H_DISPLAY		= 320;
parameter H_FRONT			=   8;
parameter H_SYNC			=  32;
parameter H_BACK			=  40;

parameter V_DISPLAY		= 240;
parameter V_BOTTOM		=   3;
parameter V_SYNC			=   4;
parameter V_TOP				=   6;
`endif

// helper constants
parameter H_SYNC_START	= H_DISPLAY + H_FRONT;
parameter H_SYNC_END		= H_DISPLAY + H_FRONT + H_SYNC - 1;
parameter H_MAX					= H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;
parameter H_LEN					= $clog2(H_MAX);
parameter V_SYNC_START	= V_DISPLAY + V_BOTTOM;
parameter V_SYNC_END		= V_DISPLAY + V_BOTTOM + V_SYNC - 1;
parameter V_MAX					= V_DISPLAY + V_BOTTOM + V_SYNC + V_TOP - 1;
parameter V_LEN					= $clog2(V_MAX);
`endif
