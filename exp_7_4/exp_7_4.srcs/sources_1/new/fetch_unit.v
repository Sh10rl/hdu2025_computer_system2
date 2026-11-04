`timescale 1ns / 1ps

// 取指模块：仅支持顺序执行（PC += 4）。
module fetch_unit (
  input  wire        clock,
  input  wire        reset,
  output wire [31:0] inst,
  output reg  [31:0] pc
);

  // 7.4 暂不支持分支，下一条地址恒为 PC+4。
  wire [31:0] pc_next = pc + 32'd4;

  always @(posedge clock or posedge reset) begin
    if (reset)
        pc <= 32'h0000_0000;
    else
        pc <= pc_next;
  end

  // 字对齐寻址：去掉字节地址低 2 位。
  Inst_ROM u_rom (
    .a   (pc[9:2]),      
    .spo (inst)
  );

endmodule

