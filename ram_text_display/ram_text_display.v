/*
Displays a grid of digits on the CRT using a RAM module.
*/

module ram_text_top(clk, reset, hsync, vsync, rgb);
input clk, reset;
output hsync, vsync;
output [2:0] rgb;

wire clk25;

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

wire display_on;
wire [8:0] hpos, vpos;

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
	.reset(reset),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

wire [4:0] row = vpos[7:3];			// 5-bit row, vpos / 8
wire [4:0] col = hpos[7:3];			// 5-bit col, hpos / 8
wire [2:0] rom_yofs = vpos[2:0];	// scanline of cell
wire [4:0] rom_bits;				// 5 pixels per scanline

wire [3:0] digit = ram_read[3:0];	// read digit from RAM
wire [2:0] xofs = hpos[2:0];		// which pixel to draw (0-7)

assign ram_addr = {row, col};

// digits ROM
digits10_case numbers(
	.digit(digit),
	.yofs(rom_yofs),
	.bits(rom_bits)
);

wire r = display_on && 0;
wire g = display_on && rom_bits[~xofs];
wire b = display_on && 0;
assign rgb = {b,g,r};

always @(posedge clk25)
	case (hpos[2:0])
		// on 7th pixel of cell
		6: begin
			// increment RAM cell
			ram_write <= (ram_read + 1);
			// enable write on last scanline of cell
			ram_we <= (vpos[2:0] == 7);
		end
		// on 8th pixel of cell
		7: begin
		// disable write
		ram_we <= 0;
		end
	endcase

endmodule
