`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test;

  localparam complete = 513;

  /* Make a reset that pulses once. */
  reg clk = 0;
  reg reset = 0;
  reg enable = 1;
  wire ready;
  wire [7:0] value;

  LFSR l1(.clk(clk), .reset(reset), .enable(enable), .ready(ready), .lfsr(value));

  // when the sensitive list is omitted in always block
  // always-block run forever
  // clock period = 2 ns
  always
  begin
    clk = !clk;
    #1;
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);
    $monitor("At time %t, rdy: %d value = %h (%0d)",
             $time, ready, value, value);
  end

  integer i;
  always @(clk)
  begin
    reset = 1;
    wait(ready);
    reset = 0;
    if (^value===1'bX) begin
      $error("Testbench failed");
      $finish;
    end

    #complete;
    $finish;
  end
endmodule // test
