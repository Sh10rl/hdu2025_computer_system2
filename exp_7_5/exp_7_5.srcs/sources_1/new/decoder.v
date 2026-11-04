`timescale 1ns / 1ps

// 实验 7.5 指令译码器。
// 在 7.4 基础上增加 LW/SW 译码与访存控制信号。
module Decoder (
    input  [31:0] inst,
    output        src1_ren,
    output        src2_ren,
    output [4:0]  src1_raddr,
    output [4:0]  src2_raddr,
    output [4:0]  reg_waddr,
    output        reg_wen,
    output reg [31:0] imm,
    output        is_lui,
    output reg [3:0]  ALU_OP,
    // 访存控制信号
    output        mem_wen,      // SW 写使能
    output        mem_to_reg    // LW 写回来源选择
);

    // 指令公共字段
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    assign src1_raddr = inst[19:15];
    assign src2_raddr = inst[24:20];
    assign reg_waddr  = inst[11:7];

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011; // addi/slli/slti/xori/andi
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;
    localparam LW     = 7'b0000011;
    localparam SW     = 7'b0100011;

    assign is_lui   = (opcode == LUI);

    // 带 rd 目标寄存器的指令才允许写回。
    assign reg_wen  = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LUI) || (opcode == AUIPC)|| (opcode == LW);

    assign src1_ren = (opcode == R_TYPE) || (opcode == I_TYPE)|| (opcode == SW) || (opcode == LW); 

    assign src2_ren = (opcode == R_TYPE) || (opcode == SW);
    
    assign mem_wen    = (opcode == SW);
    assign mem_to_reg = (opcode == LW);

    // 立即数生成：
    // - U 型：imm[31:12] 左移 12 位
    // - I 型/LW：12 位立即数符号扩展
    // - SW：S 型立即数 {inst[31:25], inst[11:7]}
    always @(*) begin
        if (opcode == LUI || opcode == AUIPC) begin
            imm = {inst[31:12], 12'b0}; 
        end else if (opcode == I_TYPE || opcode == LW) begin
            imm = {{20{inst[31]}}, inst[31:20]}; 
        end else if (opcode == SW) begin
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end else begin
            imm = 32'b0; 
        end
    end

    always @(*) begin
        case (opcode)
            R_TYPE: begin
                case (funct3)
                    3'b000: ALU_OP = (funct7[5]) ? 4'b1000 : 4'b0000; // add/sub
                    3'b001: ALU_OP = 4'b0001; // sll/slli

                    3'b010: ALU_OP = 4'b0010; // slt/slti
                    3'b011: ALU_OP = 4'b0011; // sltu

                    3'b100: ALU_OP = 4'b0100; // xor/xori
                    3'b110: ALU_OP = 4'b0110; // or
                    3'b111: ALU_OP = 4'b0111; // and/andi
                    default: ALU_OP = 4'b0000;
                endcase
            end
            I_TYPE: begin
                case (funct3)
                    3'b000: ALU_OP = 4'b0000; // addi
                    3'b001: ALU_OP = 4'b0001; // slli
                    
                    3'b010: ALU_OP = 4'b0010; // slti

                    3'b100: ALU_OP = 4'b0100; // xori
                    3'b111: ALU_OP = 4'b0111; // andi

                    default: ALU_OP = 4'b0000;
                endcase
            end
            // LW/SW 地址计算同样复用 ALU 加法。
            LUI, AUIPC, SW, LW : begin
                ALU_OP = 4'b0000; // 统一走加法路径
            end
            default: ALU_OP = 4'b0000;
        endcase
    end

endmodule
