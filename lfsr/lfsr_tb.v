`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test;

  localparam cycle = 1; // timescale
  localparam warmup = 2*cycle;
  localparam setup = 16*cycle;
  localparam complete = 513*cycle;

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
    $monitor("At time %t, value = %h (%0d)",
             $time, value, value);
  end

  integer i;
  always @(clk)
  begin
    #warmup;
    reset = 1;

    #setup;
    reset = 0;
    if (^value===1'bX) begin
      $display($time, "Value=%b has x's", value);
      for(i=0; i<8; i++) begin
        if(value[i]===1'bX) $display("value[%0d] is X",i);
        if(value[i]===1'bZ) $display("value[%0d] is Z",i);
      end
      $error("Testbench failed");
      $finish;
    end

    #complete;
    $finish;
  end
endmodule // test
