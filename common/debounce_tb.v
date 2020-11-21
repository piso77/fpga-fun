`timescale 1ns / 1ps
module test;

  /* Make a reset that pulses once. */
	reg btn;
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);

		btn = 0;
		#10;
		btn = 1;
		#20;
		btn = 0;
		#10;
		btn = 1;
		#30;
		btn = 0;
		#10;
		btn = 1;
		#40;
		btn = 0;
		#10;
		btn = 1;
		#30;
		btn = 0;
		#10;
		btn = 1;
		#1000;
		btn = 0;
		#10;
		btn = 1;
		#20;
		btn = 0;
		#10;
		btn = 1;
		#30;
		btn = 0;
		#10;
		btn = 1;
		#40;
		btn = 0;
		$finish;
 end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #2 clk = !clk;

	debouncer #(.WIDTH(6)) db(.clk(clk), .btn(btn),.state(state));
  initial
     $monitor("At time %t, btn = %b, state = %b",
              $time, btn, state);
endmodule // test
