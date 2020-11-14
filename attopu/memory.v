module memory(input clk,
              input [15:0] iAddr, // These next two signals form the instruction port
              output [15:0] iDataOut,
              input [15:0] dAddr, // These next four signals form the data port
              input dWE,
              input [15:0] dDataIn,
              output [15:0] dDataOut);

       reg [15:0] memArray [1023:0]; // Notice that Im not filling in all of memory with the memory array, ie, addresses can only from $0000 to $03ff

        initial begin
          // Load in the program/initial memory state into the memory module
          $readmemh("program.hex", memArray);
        end

        always @(posedge clk) begin
          if (dWE) begin // When the WE line is asserted, write into memory at the given address
            memArray[dAddr[9:0]] <= dDataIn; // Limit the range of the addresses
          end
        end

        assign dDataOut = memArray[dAddr[9:0]];
        assign iDataOut = memArray[iAddr[9:0]];

endmodule
