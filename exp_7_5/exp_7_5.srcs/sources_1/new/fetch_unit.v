`timescale 1ns / 1ps

module fetch_unit (
  input  wire        clock,
  input  wire        reset,        // High active reset
  output wire [31:0] inst,         // Current instruction
  output reg  [31:0] pc            // Program Counter
);

  wire [31:0] pc_next = pc + 32'd4;

  always @(posedge clock or posedge reset) begin
    if (reset)
        pc <= 32'h0000_0000;
    else
        pc <= pc_next;
  end

  Inst_ROM u_rom (
    .a   (pc[9:2]),      
    .spo (inst)
  );

endmodule

