`timescale 1ns / 1ps

module CPU (
    input         clock,
    input         reset,
    output [31:0] F,     
    output [31:0] inst,
    output [31:0] data_mem_a,   // 对应图中的 data_mem_a (即 F)
    output [31:0] data_mem_spo,  // 对应图中的 data_mem_spo  
    output        ZF,    
    output        OF     
);

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
    
    wire [31:0] src1_rdata;
    wire [31:0] src2_rdata;
    
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    
    wire        mem_wen;      // 来自 Decoder
    wire        mem_to_reg;   // 来自 Decoder
    wire [31:0] mem_rdata;     // 内存读出的数据
    wire [31:0] wb_data;      // 最终写回寄存器堆的数据

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
    
    Data_RAM u_data_ram (
        .clk (clock),
        .we  (mem_wen),
        .a   (F[9:2]),     
        .d   (src2_rdata), 
        .spo (mem_rdata)   
    );
    
    assign wb_data = mem_to_reg ? mem_rdata : F;

    assign ALU_A = src1_ren ? src1_rdata : 
                   (inst[6:0] == 7'b0110111) ? 32'b0 : pc; // 三目运算符实现Multiplexer

    assign ALU_B = (src2_ren && !mem_wen) ? src2_rdata : imm;
    
    // 新增输出. 用于后续的显示
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

