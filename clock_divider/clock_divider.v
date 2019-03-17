`timescale 1ns / 1ps

/*
 *  A clock divider in Verilog, using the cascading
 *  flip-flop method.
 */

module clock_divider(
    input clk,
    output [7:0] led
);

reg [23:0] clk_div;

// simple ripple clock divider

always @(posedge clk)
	clk_div[0] <= ~clk_div[0];

always @(posedge clk_div[0])
	clk_div[1] <= ~clk_div[1];

always @(posedge clk_div[1])
	clk_div[2] <= ~clk_div[2];

always @(posedge clk_div[2])
	clk_div[3] <= ~clk_div[3];

always @(posedge clk_div[3])
	clk_div[4] <= ~clk_div[4];

always @(posedge clk_div[4])
	clk_div[5] <= ~clk_div[5];

always @(posedge clk_div[5])
	clk_div[6] <= ~clk_div[6];

always @(posedge clk_div[6])
	clk_div[7] <= ~clk_div[7];

always @(posedge clk_div[7])
	clk_div[8] <= ~clk_div[8];

always @(posedge clk_div[8])
	clk_div[9] <= ~clk_div[9];

always @(posedge clk_div[9])
	clk_div[10] <= ~clk_div[10];

always @(posedge clk_div[10])
	clk_div[11] <= ~clk_div[11];

always @(posedge clk_div[11])
	clk_div[12] <= ~clk_div[12];

always @(posedge clk_div[12])
	clk_div[13] <= ~clk_div[13];

always @(posedge clk_div[13])
	clk_div[14] <= ~clk_div[14];

always @(posedge clk_div[14])
	clk_div[15] <= ~clk_div[15];

always @(posedge clk_div[15])
	clk_div[16] <= ~clk_div[16];

always @(posedge clk_div[16])
	clk_div[17] <= ~clk_div[17];

always @(posedge clk_div[17])
	clk_div[18] <= ~clk_div[18];

always @(posedge clk_div[18])
	clk_div[19] <= ~clk_div[19];

always @(posedge clk_div[19])
	clk_div[20] <= ~clk_div[20];

always @(posedge clk_div[20])
	clk_div[21] <= ~clk_div[21];

always @(posedge clk_div[21])
	clk_div[22] <= ~clk_div[22];

always @(posedge clk_div[22])
	clk_div[23] <= ~clk_div[23];


assign led = clk_div[23:16];

endmodule