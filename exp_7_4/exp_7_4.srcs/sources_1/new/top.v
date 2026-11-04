`timescale 1ns / 1ps

// 实验 7.4 顶层集成模块。
// - 运行单周期 CPU 核心
// - 通过 LED 输出 OF/ZF
// - 在数码管上切换显示指令或 ALU 结果
module top (
    input        clock,
    input        reset,

    input        swb,
    input        board_clk,
    
    // led[1]=OF, led[0]=ZF
    output [1:0]  led,

    // 数码管显示数据来源
    output [2:0] which,
    output [7:0] seg
);

    wire [31:0] F;
    wire [31:0] inst_mem_spo;

    wire [31:0] inst;
    wire        ZF;
    wire        OF;
    wire [31:0] data;


    CPU u_cpu (
        .clock (clock),
        .reset (reset),
        .F     (F),
        .inst  (inst),
        .ZF    (ZF),
        .OF    (OF)
    );

    assign inst_mem_spo = inst;
    assign led = {OF, ZF};

    // swb=0 显示指令字，swb=1 显示 ALU 结果。
    assign data = swb ? F : inst_mem_spo;

    Display u_display (
        .clk        (board_clk),
        .data       (data),
        .which      (which),
        .seg        (seg)
    );
endmodule
