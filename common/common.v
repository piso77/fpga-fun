// Power-Up reset
// reset_n low for (2^reset_counter_size) first clocks
module pup_reset(clk, reset_n);
	input clk;
	output reset_n;

	localparam reset_counter_size = 6;
	reg [(reset_counter_size-1):0] reset_reg = 0;

	always @(posedge clk)
		reset_reg <= reset_reg + { {(reset_counter_size-1) {1'b0}}, !reset_n};

	assign reset_n = &reset_reg;
endmodule


/*
 * Generate Power-on-Reset
 */
module pon_reset(clk, reset_n);
	input clk;
	output reset_n;

	reg [9:0] por_counter = 1023;
	always @(posedge clk) begin
		if (por_counter)
			por_counter <= por_counter-1;
	end

	assign reset_n = (por_counter == 0);
endmodule

// https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html
// Verilog code for button debouncing on FPGA
// debouncing module without creating another clock domain
// by using clock enable signal
// XXX could be used for single stepping?
module debouncer#(parameter WIDTH=18)(input clk, input btn, output state);
	wire slow_clk_en;
	wire Q0, Q1, Q2, Q2_bar;

	clock_enable #(.WIDTH(WIDTH)) u1(.clk(clk), .slow_clk_en(slow_clk_en));

	dff_en d0(.clk(clk), .ce(slow_clk_en), .D(btn), .Q(Q0));
	dff_en d1(.clk(clk), .ce(slow_clk_en), .D(Q0), .Q(Q1));
	dff_en d2(.clk(clk), .ce(slow_clk_en), .D(Q1), .Q(Q2));

	assign Q2_bar = ~Q2;
	assign state = Q1 & Q2_bar;
endmodule

// Slow clock enable for debouncing button
module clock_enable #(parameter WIDTH=18)(input clk, output slow_clk_en);
    reg [WIDTH-1:0] counter = 0;

    always @(posedge clk) begin
       counter <= counter + 1;
    end
    assign slow_clk_en = (counter == 0) ? 1'b1 : 1'b0;
endmodule

// D-flip-flop with clock enable signal for debouncing module
module dff_en(input clk, input ce, input D, output reg Q=0);

	always @(posedge clk) begin
	if(ce == 1)
		Q <= D;
	end
endmodule
