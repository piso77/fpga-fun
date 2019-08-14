module test;

  /* Make a reset that pulses once. */
  reg reset = 0;
  reg enable = 0;
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);

     # 4 reset = 1;
     # 4 reset = 0;
     # 2 enable = 1;
     # 513 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  wire [7:0] value;
  lfsr l1 (clk, reset, enable, value);

  initial
     $monitor("At time %t, value = %h (%0d)",
              $time, value, value);
endmodule // test
