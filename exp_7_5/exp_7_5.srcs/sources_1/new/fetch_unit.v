`timescale 1ns / 1ps

// 7.5 取指模块（仍为顺序执行 PC+4）。
module fetch_unit (
  input  wire        clock,
  input  wire        reset,        // 高电平复位
  output wire [31:0] inst,         // 当前指令
  output reg  [31:0] pc            // 程序计数器
);

  wire [31:0] pc_next = pc + 32'd4;

  always @(posedge clock or posedge reset) begin
    if (reset)
        pc <= 32'h0000_0000;
    else
        pc <= pc_next;
  end

  // 按字寻址：去掉字节地址低 2 位。
  Inst_ROM u_rom (
    .a   (pc[9:2]),      
    .spo (inst)
  );

endmodule
