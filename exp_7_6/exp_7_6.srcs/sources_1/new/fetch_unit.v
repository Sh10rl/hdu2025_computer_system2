`timescale 1ns / 1ps

// 实验 7.6 取指模块。
// 支持顺序执行、分支跳转、JAL/JALR 的 PC 更新。
module fetch_unit (
  input  wire        clock,
  input  wire        reset,        // 高电平复位
  
  // 来自 CPU/译码器的控制流输入
  input wire         branch_taken,
  input wire         is_jal,
  input wire         is_jalr,
  input wire  [31:0] imm,
  input wire  [31:0] rs1_data,
 
  output wire [31:0] inst,         // 当前指令
  output reg  [31:0] pc,
  output wire [31:0] pc_next_out
);

  reg  [31:0] pc_next;
  assign pc_next_out = pc_next;

  // 下一条 PC 选择优先级：
  // 1) JALR，2) JAL 或分支成立，3) 顺序执行 PC+4。
  always @(*) begin
    if (is_jalr) begin
      // JALR：目标地址为 (rs1 + imm)，最低位强制清零。
      pc_next = (rs1_data + imm) & ~32'b1;
    end
    else if (is_jal || branch_taken) begin
      // JAL 或分支成立：PC 相对跳转。
      pc_next = pc + imm;
    end
    else begin
      // 默认顺序执行。
      pc_next = pc + 4;
    end
  end

  always @(posedge clock or posedge reset) begin
    if (reset)
        pc <= 32'h0000_0000;
    else
        pc <= pc_next;
  end

  // 指令按字对齐取值。
  Inst_ROM u_rom (
    .a   (pc[9:2]),      
    .spo (inst)
  );

endmodule

