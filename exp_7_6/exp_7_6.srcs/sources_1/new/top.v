`timescale 1ns / 1ps

// 实验 7.6 顶层集成模块。
// 增加控制流相关信号的可观测性。
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
    // 从 CPU 导出的额外观测信号，用于显示和调试。
    wire [31:0] pc_next_out;
    wire [31:0] reg_wdata_out;
    wire [4:0]  reg_waddr_out;

    CPU u_cpu (
        .clock (clock),
        .reset (reset),
        .F     (F),
        .inst  (inst),
        .data_mem_a   (data_mem_a),
        .data_mem_spo (data_mem_spo),
        .ZF    (ZF),
        .OF    (OF),
        // 连接额外调试输出。
        .pc_next_out  (pc_next_out),
        .reg_wdata_out (reg_wdata_out),
        .reg_waddr_out (reg_waddr_out)
    );

    assign led = {OF, ZF};

    // 显示数据多路选择：
    // 00 指令字，01 下一条 PC，10 目标寄存器号，11 写回数据。
    always @(*) begin
        case (sw)
            2'b00: display_data = inst;         // 指令字
            2'b01: display_data = pc_next_out;   // 下一条 PC
            2'b10: display_data = {27'b0, reg_waddr_out}; // 目标寄存器编号
            2'b11: display_data = reg_wdata_out; // 写回数据
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
