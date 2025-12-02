`timescale 1ns / 1ps

module top (
    input        clock,
    input        reset,
    input  [1:0] sw,
    input        board_clk,

    // OF ZF
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

    always @(*) begin
        case (sw)
            2'b00: display_data = inst;         // instruction word
            2'b01: display_data = data_mem_a;   // data memory address
            2'b10: display_data = data_mem_spo; // data memory read data
            2'b11: display_data = F;            // ALU result
            default: display_data = inst;
        endcase
    end

    Display u_display (
        .clk        (board_clk),
        .data       (display_data),
        .which      (which),
        .seg        (seg)
    );

    assign enable = 1'b1; // keep 3-8 decoder enable asserted
endmodule