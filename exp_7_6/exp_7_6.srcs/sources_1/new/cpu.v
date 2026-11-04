`timescale 1ns / 1ps

// 实验 7.6 单周期 CPU。
// 在 7.5 基础上增加分支/跳转控制流。
module CPU (
    input         clock,
    input         reset,
    output [31:0] F,     
    output [31:0] inst,
    output [31:0] data_mem_a,  
    output [31:0] data_mem_spo, 
    output        ZF,    
    output        OF, 

    // 导出到顶层用于显示/调试的观测信号
    output [31:0] pc_next_out,
    output [31:0] reg_wdata_out,
    output [4:0] reg_waddr_out
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
    
    // 访存控制与写回选择
    wire        mem_wen;      
    wire        mem_to_reg;   
    wire [31:0] mem_rdata;   
    wire [31:0] wb_data;    

    // 取指模块导出的 next PC（转发到顶层输出）。
    wire [31:0] pc_next;
    
    // 控制流译码标志
    wire is_beq;
    wire is_bne;
    wire is_jal;
    wire is_jalr;

    // 控制流辅助组合信号
    wire is_link;
    wire is_jump_branch;
    wire is_jump;
    wire branch_taken;

    // JAL/JALR 需要把链接地址 PC+4 写入 rd。
    assign is_link = is_jal || is_jalr;
    assign is_jump = is_jal || is_jalr;
    assign is_jump_branch = is_jump || is_beq || is_bne;
    
    // 分支是否成立：
    // - BEQ 在 ZF=1 时跳转
    // - BNE 在 ZF=0 时跳转
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
        .pc_next_out (pc_next)
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
        // 控制流输出信号
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
    
    // 写回优先级：
    // is_link(PC+4) > mem_to_reg(内存读数) > ALU 结果。
    assign wb_data = is_link ? (pc + 4) : (mem_to_reg ? mem_rdata : F);

    // ALU_A 选择：
    // - 需要 rs1 时取寄存器值
    // - LUI 取 0
    // - AUIPC/JAL 相关路径取 PC
    assign ALU_A = src1_ren ? src1_rdata :
                   (inst[6:0] == 7'b0110111) ? 32'b0 : pc;

    // ALU_B 选择：
    // - 分支比较取 rs2
    // - R 型取 rs2
    // - 其他取立即数
    assign ALU_B = (is_beq || is_bne || (src2_ren && !mem_wen)) ? src2_rdata : imm;
    
    assign data_mem_a = F; 
    assign data_mem_spo = mem_rdata;

    // 导出调试观测信号到顶层。
    assign pc_next_out  = pc_next;
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

