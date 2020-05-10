module video_rom(clka, addra, douta);

  input [15:0] addra;
  output reg [7:0] douta;
  input clka;
  
  reg [7:0] rom[0:65535];

  always @(posedge clka)
  begin
		douta <= rom[addra];
  end
  
  initial
        $readmemh("blk_mem_gen_v7_3.mif", rom);
  
endmodule
