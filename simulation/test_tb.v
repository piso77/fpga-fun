module testbench;
  reg clk = 1, resetn = 0;
  wire [3:0] y;

  always #5 clk = ~clk;

  initial begin
    repeat (10) @(posedge clk);
    resetn <= 1;
    repeat (20) @(posedge clk);
    $finish;
  end

  always @(posedge clk) begin
    $display("%b", y);
  end

  test uut (
    .clk(clk),
    .resetn(resetn),
`ifdef POST_SYNTHESIS
    . \y[0] (y[0]),
    . \y[1] (y[1]),
    . \y[2] (y[2]),
    . \y[3] (y[3])
`else
    .y(y)
`endif
  );
endmodule
