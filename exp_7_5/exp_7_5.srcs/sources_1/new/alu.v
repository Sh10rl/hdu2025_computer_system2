`timescale 1ns / 1ps

module ALU (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALU_OP,
    output reg [31:0] F,
    output        ZF,
    output        OF
);

    assign ZF = (F == 32'b0);

    // Overflow flag: handle add/sub separately
    assign OF = (ALU_OP == 4'b0000) ? (~(a[31] ^ b[31]) & (a[31] ^ F[31])) :
                (ALU_OP == 4'b1000) ? ((a[31] ^ b[31]) & (a[31] ^ F[31])) :
                1'b0;

    always @(*) begin
        case (ALU_OP)
            4'b0000: F = a + b;                     // add, addi, lui, auipc
            4'b0001: F = a << b[4:0];               // sll, slli
            4'b0010: F = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // slt, slti
            4'b0011: F = (a < b) ? 32'd1 : 32'd0;   // sltu
            4'b0100: F = a ^ b;                     // xor
            4'b0110: F = a | b;                     // or
            4'b0111: F = a & b;                     // and
            4'b1000: F = a - b;                     // sub
            default: F = 32'd0;
        endcase
    end

endmodule

