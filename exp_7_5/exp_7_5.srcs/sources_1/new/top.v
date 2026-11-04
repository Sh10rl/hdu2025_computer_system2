`timescale 1ns / 1ps

// 实验 7.5 顶层集成模块。
// 增加访存相关信号的可观测性（拨码选择显示内容）。
module top (
    input        clock,
    input        reset,
    input  [1:0] sw,
    input        board_clk,

    // led[1]=OF, led[0]=ZF
    output [1:0] led,

    output [2:0]  which,
    output [7:0]  seg,
    output        enable
);

    wire [31:0] inst;
    wire [31:0] F;
    wire [31:0] data_mem_a;
    wire [31:0] data_mem_spo;
    wire        ZF;
    wire        OF;
    reg  [31:0] display_data;

    CPU u_cpu (
        .clock (clock),
        .reset (reset),
        .F     (F),
        .inst  (inst),
        .data_mem_a   (data_mem_a),
        .data_mem_spo (data_mem_spo),
        .ZF    (ZF),
        .OF    (OF)
    );

    assign led = {OF, ZF};

    // 显示数据多路选择：
    // 00 指令字，01 数据存储器地址，10 数据存储器读数，11 ALU 结果。
    always @(*) begin
        case (sw)
            2'b00: display_data = inst;         // 指令字
            2'b01: display_data = data_mem_a;   // 数据存储器地址
            2'b10: display_data = data_mem_spo; // 数据存储器读数据
            2'b11: display_data = F;            // ALU 结果
            default: display_data = inst;
        endcase
    end

    Display u_display (
        .clk        (board_clk),
        .data       (display_data),
        .which      (which),
        .seg        (seg)
    );

    assign enable = 1'b1; // 保持 3-8 译码器使能有效
endmodule
