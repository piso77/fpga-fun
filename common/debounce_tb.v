`timescale 1ns / 1ps
module test;

  /* Make a reset that pulses once. */
	reg btn;
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);

		btn = 0;
		#32;
		btn = 1;
		#64000000;
		btn = 0;
		#32000;
		btn = 1;
		#32000;
		btn = 0; 
		#10 $finish;
 end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #2 clk = !clk;

	debouncer db (.clk(clk), .btn(btn),.state(state));
  initial
     $monitor("At time %t, btn = %b, state = %b",
              $time, btn, state);
endmodule // test
