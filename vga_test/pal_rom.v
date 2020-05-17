module pal_rom(clka, addra, douta);

  input [7:0] addra;
  output reg [11:0] douta;
  input clka;
  
  reg [11:0] rom[0:255];

  always @(posedge clka)
  begin
		douta <= rom[addra];
  end
  
  initial
        $readmemh("640_480_test_palette.mem", rom);
  
endmodule
