`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:36:26 03/17/2019 
// Design Name: 
// Module Name:    binary_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module binary_counter(
    input clk,
    input reset,
    output [7:0] led
);

reg [23:0] counter;

always @(posedge clk or posedge reset)
begin
	if (reset)
		counter <= 0;
	else
		counter <= counter + 1'b1;
end

assign led[7:0] = counter[23:16];

endmodule