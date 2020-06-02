/*
Displays a grid of digits on the CRT using a RAM module.
*/

module ram_text_top(clk, stop, hsync, vsync, rgb);
input clk, stop;
output hsync, vsync;
output [2:0] rgb;

wire clk25, reset;

`ifdef XILINX
clk_wiz_v3_6 clk_pll_25(
        .clk_in1(clk),
        .clk_out1(clk25)
);
`else
pll clk_pll_25(
	.clock_in(clk),
	.clock_out(clk25),
	.locked()
);
`endif

// global power-on reset
pon_reset pon(
	.clk(clk25),
	.reset_n(reset)
);

wire display_on;
wire [9:0] hpos, vpos;

wire [9:0] ram_addr;
wire [7:0] ram_read;
reg [7:0] ram_write;
reg ram_we = 0;

ram_sync ram(
	.clk(clk25),
	.dout(ram_read),
	.din(ram_write),
	.addr(ram_addr),
	.we(ram_we)
);

hvsync_generator hvsync_gen(
	.clk(clk25),
	.reset(!reset),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

wire [6:0] row = vpos[9:3];			// 7-bit row, vpos / 8
wire [6:0] col = hpos[9:3];			// 7-bit col, hpos / 8
wire [2:0] rom_yofs = vpos[2:0];	// scanline of cell
wire [4:0] rom_bits;				// 5 pixels per scanline

wire [3:0] digit = ram_read[3:0];	// read digit from RAM
wire [2:0] xofs = hpos[2:0];		// which pixel to draw (0-7)

assign ram_addr = {row, col};

// digits ROM
`ifdef ARRAY
digits10_array numbers(
	.digit(digit),
	.yofs(rom_yofs),
	.bits(rom_bits)
);
`else
digits10_case numbers(
	.digit(digit),
	.yofs(rom_yofs),
	.bits(rom_bits)
);
`endif


wire r = display_on && 0;
wire g = display_on && (xofs >= 3'b011) && rom_bits[~xofs];
wire b = display_on && 0;
assign rgb = {b,g,r};

wire [7:0] lfsr;
// LFSR with period = 2^8-1
LFSR lfsr_gen(
	.clk(clk25),
	.reset(!reset),
	.enable(1),
	.lfsr(lfsr)
);

reg [2:0] cnt;
always @(posedge clk25) begin
	ram_we <= 0;
	if (hpos==0 && vpos==0 && stop==0) begin
		cnt <= cnt + 1;
	end
	if (hpos[2:0]==0 && vpos[2:0]==0 && cnt==7) begin
		ram_we <= 1;
		ram_write <= lfsr;
	end
end
endmodule
