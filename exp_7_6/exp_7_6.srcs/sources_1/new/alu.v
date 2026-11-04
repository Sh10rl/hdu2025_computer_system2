`timescale 1ns / 1ps

// 实验 7.6 算术逻辑单元（ALU）。
// 复用前一实验实现；分支比较通过减法 + ZF 完成。
module ALU (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALU_OP,
    output reg [31:0] F,
    output        ZF,
    output        OF
);

    assign ZF = (F == 32'b0);

    // 溢出标志：加法与减法分别判断
    assign OF = (ALU_OP == 4'b0000) ? (~(a[31] ^ b[31]) & (a[31] ^ F[31])) :
                (ALU_OP == 4'b1000) ? ((a[31] ^ b[31]) & (a[31] ^ F[31])) :
                1'b0;

    always @(*) begin
        case (ALU_OP)
            4'b0000: F = a + b;                     // 加法类
            4'b0001: F = a << b[4:0];               // 逻辑左移
            4'b0010: F = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // 有符号比较
            4'b0011: F = (a < b) ? 32'd1 : 32'd0;   // 无符号比较
            4'b0100: F = a ^ b;                     // 按位异或
            4'b0110: F = a | b;                     // 按位或
            4'b0111: F = a & b;                     // 按位与
            4'b1000: F = a - b;                     // 减法
            default: F = 32'd0;
        endcase
    end

endmodule

