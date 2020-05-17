module video_rom(clka, addra, douta);

  input [18:0] addra;
  output reg [7:0] douta;
  input clka;
  
  reg [7:0] rom[0:307199];

  always @(posedge clka)
  begin
		douta <= rom[addra];
  end
  
  initial
        $readmemh("640_480_test.mem", rom);
  
endmodule
