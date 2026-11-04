`timescale 1ns / 1ps

// 实验 7.4 单周期 CPU。
// 数据通路：取指 -> 译码 -> 寄存器堆 -> ALU -> 写回。
module CPU (
    input         clock,
    input         reset,
    output [31:0] F,     
    output [31:0] inst,  
    output        ZF,    
    output        OF     
);

    // 译码与控制信号
    wire [31:0] pc;
    wire [31:0] imm;
    wire [4:0]  src1_raddr;
    wire [4:0]  src2_raddr;
    wire [4:0]  reg_waddr;
    wire        reg_wen;
    wire        src1_ren;
    wire        src2_ren;
    wire        is_lui;
    wire [3:0]  ALU_OP;
    
    // 寄存器堆读数据
    wire [31:0] src1_rdata;
    wire [31:0] src2_rdata;
    
    // ALU 输入操作数
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;

    fetch_unit u_fetch (
        .clock (clock),
        .reset (reset),
        .inst  (inst),
        .pc    (pc)
    );

    Decoder u_decoder (
        .inst       (inst),

        .src1_ren   (src1_ren),
        .src2_ren   (src2_ren),
        .src1_raddr (src1_raddr),
        .src2_raddr (src2_raddr),
        .reg_waddr  (reg_waddr),
        .reg_wen    (reg_wen),
        .imm        (imm),
        .is_lui     (is_lui),
        .ALU_OP     (ALU_OP)
    );

    RegFile u_regfile (
        .clk        (clock),
        .reset      (reset),
        .src1_raddr (src1_raddr),
        .src2_raddr (src2_raddr),
        .reg_waddr  (reg_waddr),
        .reg_wen    (reg_wen),
        .reg_wdata  (F),
        .src1_rdata (src1_rdata),
        .src2_rdata (src2_rdata)
    );

    // ALU_A 选择：
    // - 使用 rs1 时取寄存器值
    // - LUI 取 0
    // - AUIPC 取 PC
    assign ALU_A = src1_ren ? src1_rdata :
                   (inst[6:0] == 7'b0110111) ? 32'b0 : pc;

    // ALU_B 选择：R 型取寄存器，其余取立即数。
    assign ALU_B = src2_ren ? src2_rdata : imm;

    ALU u_alu (
        .a      (ALU_A),
        .b      (ALU_B),
        .ALU_OP (ALU_OP),
        .F      (F),
        .ZF     (ZF),
        .OF     (OF)
    );

endmodule

