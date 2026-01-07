`timescale 1ns / 1ps

module fetch_unit (
  input  wire        clock,
  input  wire        reset,        // High active reset
  
  //新增jmp相关接口 
  input wire         branch_taken, // 是否有条件分支，根据ZF标志判断2
  input wire         is_jal,
  input wire         is_jalr,// jump and link register signal
  input wire  [31:0] imm,          // (偏移量)
  input wire  [31:0] rs1_data,    // rs1寄存器数据，用于JALR
 
  output wire [31:0] inst,         // Current instruction
  output reg  [31:0] pc,            // Program Counter
  output wire [31:0] pc_next_out    // Next Program Counter
);

  reg  [31:0] pc_next;
  assign pc_next_out = pc_next;
  //更新pc_next逻辑，考虑跳转指令
  always @(*) begin 
    if (is_jalr) begin
      //JALR:PC = (rs1+imm) & ~1 
      pc_next = (rs1_data + imm) & ~32'b1; //即32'hffff_fffe 与地位与保证最低为清零实现对齐
    end
    else if (is_jal || branch_taken) begin
      //JAL or branch taken: PC = PC + imm
      pc_next = pc + imm;
    end
    else begin
      //默认PC + 4 顺序执行
      pc_next = pc + 4;
    end
  end

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

