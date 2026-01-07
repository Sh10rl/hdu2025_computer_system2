`timescale 1ns / 1ps

module top (
    input        clock,
    input        reset,

    input        swb,
    input        board_clk,
    
    // OF ZF
    output [1:0]  led, 

    // F OR inst_mem_spo
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
    assign data = swb ? F : inst_mem_spo;

    Display u_display (
        .clk        (board_clk),
        .data       (data),
        .which      (which),
        .seg        (seg)
    );
endmodule