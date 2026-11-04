`timescale 1ns / 1ps

// 实验 7.4 算术逻辑单元（ALU）。
// 标志位说明：
// - ZF：结果是否为 0
// - OF：加/减法的有符号溢出
module ALU (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALU_OP,
    output reg [31:0] F,
    output        ZF,
    output        OF
);

    assign ZF = (F == 32'b0);

    assign OF = (ALU_OP == 4'b0000) ? (~(a[31] ^ b[31]) & (a[31] ^ F[31])) : // 加法溢出
                (ALU_OP == 4'b1000) ? ((a[31] ^ b[31]) & (a[31] ^ F[31])) : // 减法溢出
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
