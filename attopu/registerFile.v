module registerFile(input clk,
                    input rst,
                    input [15:0] in,     // Data for write back register
                    input [1:0] inSel,   // Register number to write back to
                    input inEn,          // Dont actually write back unless asserted
                    input [1:0] outSel1, // Register number for out1
                    input [1:0] outSel2, // Register number for out2
                    output [15:0] out1,
                    output [15:0] out2);

  reg [15:0] regs[3:0];

  // Actual register file storage
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      regs[3] <= 16'd0;
      regs[2] <= 16'd0;
      regs[1] <= 16'd0;
      regs[0] <= 16'd0;
    end
    else begin
      if (inEn) begin // Only write back when inEn is asserted, not all instructions write to the register file!
        regs[inSel] <= in;
      end
    end
  end

  // Output registers
  assign out1 = regs[outSel1];
  assign out2 = regs[outSel2];

endmodule
