`timescale 1ns / 1ps

module CPU (
    input         clock,
    input         reset,
    output [31:0] F,     
    output [31:0] inst,
    output [31:0] data_mem_a,  
    output [31:0] data_mem_spo, 
    output        ZF,    
    output        OF, 

    //增加接口实现在top模块的输出
    output [31:0] pc_next_out,  //来自fetch_unit的pc_next 
    output [31:0] reg_wdata_out, //来自wb_data 
    output [4:0] reg_waddr_out  //目标寄存器地址，来自decoder的reg_waddr 
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
    
    wire        mem_wen;      
    wire        mem_to_reg;   
    wire [31:0] mem_rdata;   
    wire [31:0] wb_data;    
    
    //7.6 
    wire is_beq;
    wire is_bne;
    wire is_jal;
    wire is_jalr;

    //组合信号判断 
    wire is_link;
    wire is_jump_branch;
    wire is_jump;
    wire branch_taken;

    //逻辑信号生成 
    assign is_link = is_jal || is_jalr;
    assign is_jump = is_jal || is_jalr;
    assign is_jump_branch = is_jump || is_beq || is_bne;
    
    //计算branch_taken beq 且ZF=1，或bne且ZF=0
    assign branch_taken = (is_beq && ZF) || (is_bne && !ZF);
    fetch_unit u_fetch (
        .clock (clock),
        .reset (reset),

        .branch_taken (branch_taken),
        .is_jal       (is_jal),
        .is_jalr      (is_jalr),
        .imm          (imm),
        .rs1_data     (src1_rdata),

        .inst  (inst),
        .pc    (pc),
        .pc_next_out (pc_next_out)
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
        .ALU_OP     (ALU_OP),
        //连接新输出 
        .is_beq     (is_beq),
        .is_bne     (is_bne),
        .is_jal     (is_jal),
        .is_jalr    (is_jalr)
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
    
    //写回数据选择修改，is_link (PC+4) > mem_to_reg(mem) > ALU(F) 用于写回链接指令的写回值。
    assign wb_data = is_link ? (pc + 4) : (mem_to_reg ? mem_rdata : F);

    assign ALU_A = src1_ren ? src1_rdata : 
                   (inst[6:0] == 7'b0110111) ? 32'b0 : pc;
    // 对于 Branch 指令 (is_beq/is_bne)，ALU 需要比较两个寄存器，所以必须选 src2_rdata
    // 对于 R-Type，选 src2_rdata
    // 其他 (I-Type, SW, LUI, AUIPC, JAL) 选 imm
    assign ALU_B = (is_beq || is_bne || (src2_ren && !mem_wen)) ? src2_rdata : imm;
    
    assign data_mem_a = F; 
    assign data_mem_spo = mem_rdata;

    // 连接输出到CPU内部 
    assign pc_next_out  = u_fetch.pc_next_out;
    assign reg_wdata_out = wb_data;
    assign reg_waddr_out = reg_waddr;

    ALU u_alu (
        .a      (ALU_A),
        .b      (ALU_B),
        .ALU_OP (ALU_OP),
        .F      (F),
        .ZF     (ZF),
        .OF     (OF)
    );

endmodule

