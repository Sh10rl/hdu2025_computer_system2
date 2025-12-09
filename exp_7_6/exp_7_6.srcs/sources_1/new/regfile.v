`timescale 1ns / 1ps

module RegFile (
    input         clk,
    input         reset,
    input  [4:0]  src1_raddr,
    input  [4:0]  src2_raddr,
    input  [4:0]  reg_waddr,
    input         reg_wen,
    input  [31:0] reg_wdata,
    output [31:0] src1_rdata,
    output [31:0] src2_rdata
);

    reg [31:0] registers [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = i;
        end
        registers[0] = 32'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
             for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= i;
            end
            registers[0] <= 32'b0;
        end else if (reg_wen && (reg_waddr != 5'd0)) begin
            registers[reg_waddr] <= reg_wdata;
        end
    end

    assign src1_rdata = (src1_raddr == 5'd0) ? 32'b0 : registers[src1_raddr];
    assign src2_rdata = (src2_raddr == 5'd0) ? 32'b0 : registers[src2_raddr];

endmodule

