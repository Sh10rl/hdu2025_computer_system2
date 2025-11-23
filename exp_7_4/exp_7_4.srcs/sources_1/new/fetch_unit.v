`timescale 1ns / 1ps

module fetch_unit (
  input  wire        clock,
  input  wire        reset,
  output wire [31:0] inst,
  output reg  [31:0] pc
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

