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
    output        mem_wen,      
    output        mem_to_reg,
    // 新增跳转信号 
    output        is_beq,
    output        is_bne,
    output        is_jal,
    output        is_jalr
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    assign src1_raddr = inst[19:15];
    assign src2_raddr = inst[24:20];
    assign reg_waddr  = inst[11:7];

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011; // addi, slli, slti
    localparam B_TYPE = 7'b1100011; // beq, bne
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;
    localparam LW     = 7'b0000011; 
    localparam SW     = 7'b0100011;
    // newtype 
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111; 


    //新增控制信号判断
    assign is_lui  = (opcode == LUI);
    assign is_jal  = (opcode == JAL);
    assign is_jalr = (opcode == JALR);
    assign is_beq  = (opcode == B_TYPE) && (funct3 == 3'b000);
    assign is_bne  = (opcode == B_TYPE) && (funct3 == 3'b001);

    //update for reg_wen and src1 and src2
    assign reg_wen  = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LUI) || (opcode == AUIPC)|| (opcode == LW) || (opcode == JAL) || (opcode == JALR);

    assign src1_ren = (opcode == R_TYPE) || (opcode == I_TYPE)|| (opcode == SW) || (opcode == LW) || (opcode == JALR) || (opcode == B_TYPE); 

    assign src2_ren = (opcode == R_TYPE) || (opcode == SW) || (opcode == B_TYPE);
    
    assign mem_wen    = (opcode == SW);
    assign mem_to_reg = (opcode == LW);

    always @(*) begin
        if (opcode == LUI || opcode == AUIPC) begin
            imm = {inst[31:12], 12'b0}; 
        end else if (opcode == I_TYPE || opcode == LW || opcode == JALR) begin // 新增 JALR, 属于 I 型指令, 直接复用
            imm = {{20{inst[31]}}, inst[31:20]}; 
        end else if (opcode == SW) begin
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end else if (opcode == B_TYPE) begin //B-TYPE 注意位拼接和左移1位
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        end else if (opcode == JAL) begin //JAL 注意位拼接和左移1位
            imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
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
            I_TYPE,JALR: begin // ALR 使用加法计算目标地址(基址+偏移)，在这里仅做加法，跳转逻辑在fetch/cpu处理
                case (funct3)
                    3'b000: ALU_OP = 4'b0000; // addi / jalr
                    3'b001: ALU_OP = 4'b0001; // slli
                    
                    3'b010: ALU_OP = 4'b0010; // slti

                    3'b100: ALU_OP = 4'b0100; // xori
                    3'b111: ALU_OP = 4'b0111; // andi

                    default: ALU_OP = 4'b0000;
                endcase
            end
            B_TYPE: begin
                ALU_OP = 4'b1000; // branch 比较使用 sub 和ALU的ZF标志位
            end
            LUI, AUIPC, SW, LW,JAL: begin // 直接复用 ALU 的 ADD
                ALU_OP = 4'b0000; // add (0 + imm); add (pc + imm)
            end
            default: ALU_OP = 4'b0000;
        endcase
    end

endmodule
