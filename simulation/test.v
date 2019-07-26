module test(input clk, resetn, output reg [3:0] y);
  always @(posedge clk)
    y <= resetn ? y + 1 : 0;
endmodule
