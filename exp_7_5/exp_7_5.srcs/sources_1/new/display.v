`timescale 1ns / 1ps

// 8 位数码管驱动（动态扫描）。
module Display(
    input           clk,
    input  [31:0]   data,

    output reg [2:0] which,
    output reg [7:0] seg,

    output reg [10:0] count,
    output reg [3:0] digit
);

    initial begin
        which = 3'b000;
        seg = 8'hFF; 
        count = 11'd0;
        digit = 4'hF; 
    end

    // 分频计数器，用于控制扫描频率。
    always @(posedge clk) begin
        count <= count + 1'b1;
    end

    // 计数器溢出时轮换位选。
    always @(negedge clk) begin
        if (&count) begin
            which <= which + 1'b1; // 9765.625HZ
        end
    end

    // 根据位选 which 取当前要显示的 4bit 数据。
    always @(*) begin
        case (which)
            3'd0:   digit = data[31:28];
            3'd1:   digit = data[27:24];
            3'd2:   digit = data[23:20];
            3'd3:   digit = data[19:16];
            3'd4:   digit = data[15:12];
            3'd5:   digit = data[11:8];
            3'd6:   digit = data[7:4];
            3'd7:   digit = data[3:0];
            default: digit = 4'hF;     
        endcase
    end

    // 4bit 十六进制到数码管段码映射。
    always @(*) begin
        case (digit)
            4'h0:   seg = 8'b00000011; // "0"
            4'h1:   seg = 8'b10011111; // "1"
            4'h2:   seg = 8'b00100101; // "2"
            4'h3:   seg = 8'b00001101; // "3"
            4'h4:   seg = 8'b10011001; // "4"
            4'h5:   seg = 8'b01001001; // "5"
            4'h6:   seg = 8'b01000001; // "6"
            4'h7:   seg = 8'b00011111; // "7"
            4'h8:   seg = 8'b00000001; // "8"
            4'h9:   seg = 8'b00001001; // "9"
            4'hA:   seg = 8'b00010001; // "A"
            4'hB:   seg = 8'b11000001; // "b"
            4'hC:   seg = 8'b01100011; // "C"
            4'hD:   seg = 8'b10000101; // "d"
            4'hE:   seg = 8'b01100001; // "E"
            4'hF:   seg = 8'b01110001; // "F"
            default: seg = 8'b11111111; // 熄灭
        endcase
    end

endmodule
