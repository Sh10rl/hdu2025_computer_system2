`timescale 1ns / 1ps

// 实验 7.5 单周期 CPU。
// 在 7.4 基础上增加 lw/sw 访存数据通路。
module CPU (
    input         clock,
    input         reset,
    output [31:0] F,     
    output [31:0] inst,
    output [31:0] data_mem_a,  
    output [31:0] data_mem_spo, 
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
    
    // 访存控制与写回选择信号
    wire        mem_wen;
    wire        mem_to_reg;
    wire [31:0] mem_rdata;
    wire [31:0] wb_data;

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
        .mem_wen    (mem_wen),
        .mem_to_reg (mem_to_reg),
        .ALU_OP     (ALU_OP)
    );

    RegFile u_regfile (
        .clk        (clock),
        .reset      (reset),
        .src1_raddr (src1_raddr),
        .src2_raddr (src2_raddr),
        .reg_waddr  (reg_waddr),
        .reg_wen    (reg_wen),
        .reg_wdata  (wb_data),
        .src1_rdata (src1_rdata),
        .src2_rdata (src2_rdata)
    );
    
    // 数据存储器：
    // - 地址取 F[9:2]（按字寻址）
    // - 写数据来自 rs2
    Data_RAM u_data_ram (
        .clk (clock),
        .we  (mem_wen),
        .a   (F[9:2]),     
        .d   (src2_rdata), 
        .spo (mem_rdata)   
    );
    
    // 写回多路选择：内存读数或 ALU 结果。
    assign wb_data = mem_to_reg ? mem_rdata : F;

    // ALU_A 选择：
    // - 使用 rs1 时取寄存器值
    // - LUI 取 0
    // - AUIPC 取 PC
    assign ALU_A = src1_ren ? src1_rdata :
                   (inst[6:0] == 7'b0110111) ? 32'b0 : pc;

    // ALU_B 选择：
    // - R 型取 rs2
    // - I 型/lw/sw/lui/auipc 取立即数
    assign ALU_B = (src2_ren && !mem_wen) ? src2_rdata : imm;
    
    // 导出访存观测信号到顶层模块。
    assign data_mem_a = F;
    assign data_mem_spo = mem_rdata;

    ALU u_alu (
        .a      (ALU_A),
        .b      (ALU_B),
        .ALU_OP (ALU_OP),
        .F      (F),
        .ZF     (ZF),
        .OF     (OF)
    );

endmodule
