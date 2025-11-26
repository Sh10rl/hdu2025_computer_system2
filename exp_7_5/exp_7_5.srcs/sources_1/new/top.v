`timescale 1ns / 1ps

module top (
    input         clock,
    input         board_clk,
    input         reset,
    input  [1:0]  sw, // 修改为两个开关

    output [31:0] inst_mem_spo,
    output [31:0] F,
    output [31:0] data_mem_a,   // 数据存储器地址
    output [31:0] data_mem_spo, // 数据存储器读出数据
    output [1:0]  led,

    output [2:0]  which,
    output [7:0]  seg
);

    wire [31:0] inst;
    wire        ZF;
    wire        OF;
    reg [31:0] data; // 改为 reg, 方便后续用 case

    CPU u_cpu (
        .clock (clock),
        .reset (reset),
        .F     (F),
        .inst  (inst),
        // 绑定新输出
        .data_mem_a   (data_mem_a),
        .data_mem_spo (data_mem_spo),
        .ZF    (ZF),
        .OF    (OF)
    );

    assign inst_mem_spo = inst;
    assign led = {OF, ZF};
    always @(*) begin
        case (sw)
            2'b00: data = inst;         
            2'b01: data = data_mem_a;   
            2'b10: data = data_mem_spo;
            2'b11: data = F;           
            default: data = inst;
        endcase
    end

    Display u_display (
        .clk        (board_clk),
        .data       (data),
        .which      (which),
        .seg        (seg)
    );
endmodule