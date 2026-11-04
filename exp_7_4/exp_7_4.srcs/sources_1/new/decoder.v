`timescale 1ns / 1ps

// 实验 7.4 指令译码器。
// 生成寄存器访问信号、立即数、写使能与 ALU_OP。
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
    output reg [3:0]  ALU_OP
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

    assign is_lui = (opcode == LUI);

    // 带 rd 目标寄存器的指令才允许写回。
    assign reg_wen = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LUI) || (opcode == AUIPC);

    assign src1_ren = (opcode == R_TYPE) || (opcode == I_TYPE);

    assign src2_ren = (opcode == R_TYPE);

    // 立即数生成：
    // - U 型：imm[31:12] 左移 12 位
    // - I 型：12 位立即数符号扩展
    always @(*) begin
        if (opcode == LUI || opcode == AUIPC) begin
            imm = {inst[31:12], 12'b0}; // U 型立即数
        end else if (opcode == I_TYPE) begin
            imm = {{20{inst[31]}}, inst[31:20]}; // I 型立即数
        end else begin
            imm = 32'b0; // R 型无立即数
        end
    end

    always @(*) begin
        case (opcode)
            R_TYPE: begin
                case (funct3)
                    // ALU_OP 编码与 ALU.v 中定义一致。
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
            LUI, AUIPC: begin
                ALU_OP = 4'b0000; // LUI/AUIPC 都走加法器
            end
            default: ALU_OP = 4'b0000;
        endcase
    end

endmodule
