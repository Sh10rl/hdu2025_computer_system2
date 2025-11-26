`timescale 1ns / 1ps

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
    // 新增内存写使能, 内存写入寄存器使能
    output        mem_wen,      // 控制 寄存器数据写入内存 使能(SW)
    output        mem_to_reg    // 控制 内存数据写入寄存器 使能(LW)
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    assign src1_raddr = inst[19:15];
    assign src2_raddr = inst[24:20];
    assign reg_waddr  = inst[11:7];

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011; // addi, slli, slti
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;
    localparam LW     = 7'b0000011; // lw [新增]
    localparam SW     = 7'b0100011; // sw [新增]

    assign is_lui   = (opcode == LUI);

    // Use more robust ways instead of hardcoding for `reg_wen`
    assign reg_wen  = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LUI) || (opcode == AUIPC)|| (opcode == LW);

    assign src1_ren = (opcode == R_TYPE) || (opcode == I_TYPE)|| (opcode == SW) || (opcode == LW); 

    assign src2_ren = (opcode == R_TYPE) || (opcode == SW);
    
    assign mem_wen    = (opcode == SW);
    assign mem_to_reg = (opcode == LW);

    always @(*) begin
        if (opcode == LUI || opcode == AUIPC) begin
            imm = {inst[31:12], 12'b0}; 
        end else if (opcode == I_TYPE || opcode == LW) begin // 新增 LW, 属于 I 型指令, 直接复用
            imm = {{20{inst[31]}}, inst[31:20]}; 
        end else if (opcode == SW) begin // 新增 SW, 属于 S 型指令, 需要重新写
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end else begin
            imm = 32'b0; 
        end
    end

    always @(*) begin
        case (opcode)
            R_TYPE: begin
                case (funct3)
                    3'b000: ALU_OP = (funct7[5]) ? 4'b1000 : 4'b0000; // sub
                    3'b001: ALU_OP = 4'b0001; // sll

                    3'b010: ALU_OP = 4'b0010; // slt
                    3'b011: ALU_OP = 4'b0011; // sltu

                    3'b100: ALU_OP = 4'b0100; // xor
                    3'b110: ALU_OP = 4'b0110; // or
                    3'b111: ALU_OP = 4'b0111; // and
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
            LUI, AUIPC, SW, LW : begin // 直接复用 ALU 的 ADD
                ALU_OP = 4'b0000; // add (0 + imm); add (pc + imm)
            end
            default: ALU_OP = 4'b0000;
        endcase
    end

endmodule
