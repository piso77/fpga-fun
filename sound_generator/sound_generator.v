/*
	Sound generator module.
	This module has a square-wave oscillator (VCO) which can be modulated by a
	low-frequency oscillator (LFO), and also mixed with a LFSR noise source.
*/

module sound_generator(clk, reset, spkr, lfo_freq, noise_freq, vco_freq,
					   vco_select, noise_select, lfo_shift, mixer);
input clk, reset;
output reg spkr = 0;

input [9:0] lfo_freq;			// LFO frequency
input [11:0] noise_freq;		// noise frequency
input [11:0] vco_freq;			// VCO frequency
input vco_select;				// 1 = LFO modulates VCO
input noise_select;				// 1 = LFO modulates Noise
input [2:0] lfo_shift;			// LFO modulation depth
input [2:0] mixer;				// mix enable {LFO, Noise, VCO}

reg [3:0] div16;				// deivide-by-16 counter
reg [17:0] lfo_count;			// LFO counter
reg lfo_state;					// LFO output
reg [12:0] noise_count;			// Noise counter
reg noise_state;				// Noise output
reg [12:0] vco_count;			// VCO counter
reg vco_state;					// VCO output

wire [15:0] lfsr;				// LFSR output

LFSR #(16'b1000000001011,0) lfsr_gen(
	.clk(clk),
	.reset(reset),
	.enable(div16 == 0 && noise_count == 0),
	.lfsr(lfsr)
);

// generate triangle waveform from LFO
wire [11:0] lfo_triangle = lfo_count[17] ? ~lfo_count[17:6] : lfo_count[17:6];
wire [11:0] vco_delta = lfo_triangle >> lfo_shift;

always @(posedge clk) begin
	// divide clock by 64
	div16 <= div16 + 1;
	if (div16 == 0) begin
		// VCO oscillator
		if (reset || vco_count == 0) begin
			vco_state <= ~vco_state;
			if (vco_select)
				vco_count <= vco_freq + vco_delta;
			else
				vco_count <= vco_freq + 0;
		end else
			vco_count <= vco_count  - 1;
		// LFO oscillator
		if (reset || lfo_count == 0) begin
			lfo_state <= ~lfo_state;
			lfo_count <= {lfo_freq, 8'b0};
		end else
			lfo_count <= lfo_count - 1;
		// Noise oscillator
		if (reset || noise_count == 0) begin
			if (lfsr[0])
				noise_state <= ~noise_state;
			if (noise_select)
				noise_count <= noise_freq + vco_delta;
			else
				noise_count <= noise_freq + 0;
		end else
			noise_count <= noise_count - 1;
		// Mixer
		spkr <= (lfo_state | ~mixer[2]) &
				(noise_state | ~mixer[1]) &
				(vco_state | ~mixer[0]);
	end
end
endmodule

module test_sndchip_top(clk, reset, hsync, vsync, rgb, spkr);

input clk, reset;
output hsync, vsync;
output spkr;
output [2:0] rgb;

reg [2:0] div5 = 0;
reg clk5;
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

hvsync_generator hvsync_gen(
	.clk(clk25),
	.reset(reset),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(),
	.hpos(),
	.vpos()
);

always @(posedge clk25) begin
	div5 <= div5 + 1;
	if (div5[2]) begin
		clk5 <= ~clk5;
		div5 <= 3'b0;
	end
end

sound_generator sndgen(
	.clk(clk5),
	.reset(reset),
	.spkr(spkr),
	.lfo_freq(1000),
	.noise_freq(90),
	.vco_freq(250),
	.vco_select(1),
	.noise_select(1),
	.lfo_shift(1),
	.mixer(3)
);

assign rgb = {spkr, 1'b0, 1'b0};

endmodule
