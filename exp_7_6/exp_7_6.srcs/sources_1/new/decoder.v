`timescale 1ns / 1ps

// 实验 7.6 指令译码器。
// 在 7.5 的访存版本上增加分支/跳转译码。
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
    // 控制流译码标志
    output        is_beq,
    output        is_bne,
    output        is_jal,
    output        is_jalr
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
    localparam B_TYPE = 7'b1100011; // beq/bne
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;
    localparam LW     = 7'b0000011;
    localparam SW     = 7'b0100011;
    // 控制流指令类型
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111;


    // 控制流类型识别
    assign is_lui  = (opcode == LUI);
    assign is_jal  = (opcode == JAL);
    assign is_jalr = (opcode == JALR);
    assign is_beq  = (opcode == B_TYPE) && (funct3 == 3'b000);
    assign is_bne  = (opcode == B_TYPE) && (funct3 == 3'b001);

    // 寄存器写使能与源操作数读使能
    assign reg_wen  = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LUI) || (opcode == AUIPC)|| (opcode == LW) || (opcode == JAL) || (opcode == JALR);

    assign src1_ren = (opcode == R_TYPE) || (opcode == I_TYPE)|| (opcode == SW) || (opcode == LW) || (opcode == JALR) || (opcode == B_TYPE); 

    assign src2_ren = (opcode == R_TYPE) || (opcode == SW) || (opcode == B_TYPE);
    
    assign mem_wen    = (opcode == SW);
    assign mem_to_reg = (opcode == LW);

    // 立即数生成：
    // - U 型：imm[31:12] 左移 12 位
    // - I 型/LW/JALR：12 位立即数符号扩展
    // - SW：S 型立即数
    // - B/J 型：分支/跳转立即数，最低位补 0（地址对齐）
    always @(*) begin
        if (opcode == LUI || opcode == AUIPC) begin
            imm = {inst[31:12], 12'b0}; 
        end else if (opcode == I_TYPE || opcode == LW || opcode == JALR) begin
            imm = {{20{inst[31]}}, inst[31:20]}; 
        end else if (opcode == SW) begin
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end else if (opcode == B_TYPE) begin
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        end else if (opcode == JAL) begin
            imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
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
            I_TYPE, JALR: begin // JALR 目标地址 = rs1 + imm
                case (funct3)
                    3'b000: ALU_OP = 4'b0000; // addi/jalr
                    3'b001: ALU_OP = 4'b0001; // slli
                    
                    3'b010: ALU_OP = 4'b0010; // slti

                    3'b100: ALU_OP = 4'b0100; // xori
                    3'b111: ALU_OP = 4'b0111; // andi

                    default: ALU_OP = 4'b0000;
                endcase
            end
            B_TYPE: begin
                ALU_OP = 4'b1000; // 分支比较使用减法与 ZF
            end
            LUI, AUIPC, SW, LW, JAL: begin // 地址与跳转基址计算
                ALU_OP = 4'b0000; // 统一走加法路径
            end
            default: ALU_OP = 4'b0000;
        endcase
    end

endmodule
