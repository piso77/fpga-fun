`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test;

  localparam cycle = 1; // timescale
  localparam init = 4*cycle;
  localparam start = 16*cycle;
  localparam finish = 513*cycle;

  /* Make a reset that pulses once. */
  reg clk = 0;
  reg reset = 0;
  reg enable = 1;
  wire [7:0] value;

  LFSR l1(.clk(clk), .reset(reset), .enable(enable), .lfsr(value));

  // when the sensitive list is omitted in always block
  // always-block run forever
  // clock period = 2 ns
  always
  begin
    clk = !clk;
    #cycle;
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);

    #init reset = 1;
    #start reset = 0;
    #finish $finish;
  end

  initial
    $monitor("At time %t, value = %h (%0d)",
             $time, value, value);
endmodule // test
