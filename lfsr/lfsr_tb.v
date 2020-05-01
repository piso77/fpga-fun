module test;

  /* Make a reset that pulses once. */
  reg clk = 0;
  reg reset = 0;
  reg enable = 1;
  wire [7:0] value;

  LFSR l1(.clk(clk), .reset(reset), .enable(enable), .lfsr(value));

  /* Make a regular pulsing clock. */
  always #1 clk = !clk;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);

    # 4 reset = 1;
    # 16 reset = 0;
    # 513 $finish;
  end

  initial
    $monitor("At time %t, value = %h (%0d)",
             $time, value, value);
endmodule // test
