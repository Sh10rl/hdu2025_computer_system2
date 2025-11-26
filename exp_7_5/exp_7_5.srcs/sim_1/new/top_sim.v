`timescale 1ns / 1ps

module tb_top;

    // Inputs
    reg clock;
    reg board_clk;
    reg reset;
    reg [1:0] sw;

    // Outputs
    wire [31:0] inst_mem_spo;
    wire [31:0] F;
    wire [31:0] data_mem_a;
    wire [31:0] data_mem_spo;
    wire [1:0]  led;
    wire [2:0]  which;
    wire [7:0]  seg;

    // 实例化 Top 模块
    top uut (
        .clock(clock), 
        .board_clk(board_clk), 
        .reset(reset), 
        .sw(sw), 
        .inst_mem_spo(inst_mem_spo), 
        .F(F), 
        .data_mem_a(data_mem_a), 
        .data_mem_spo(data_mem_spo), 
        .led(led), 
        .which(which), 
        .seg(seg)
    );

    // 时钟生成 (10ns 周期)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
    initial begin
        board_clk = 0;
        forever #5 board_clk = ~board_clk;
    end

    // --- 【核心修改：打印输出日志】 ---
    initial begin
        // 打印表头
        $display("\n=======================================================================================");
        $display("|   Time(ns)  |  Instruction (Hex) |  ALU_Result/Addr (Hex) |  Mem_Read_Data (Hex) |");
        $display("=======================================================================================");
    end

    // 在时钟下降沿采样并打印 (此时信号最稳定)
    always @(negedge clock) begin
        if (!reset) begin // 复位结束后才开始打印
            // %t: 时间, %h: 16进制
            $display("|  %5t ns   |      %8h      |        %8h        |       %8h       |", 
                     $time, inst_mem_spo, data_mem_a, data_mem_spo);
        end
    end
    // ------------------------------------

    // 测试流程
    initial begin
        // 初始化
        reset = 1;
        sw = 0;
        #20; // 复位 20ns
        
        reset = 0; // 释放复位, CPU 开始运行
        
        // 你的代码大约有 11 条指令，每条 10ns
        // 运行 150ns 足够跑完所有指令并看到结果
        #150; 
        
        $display("=======================================================================================\n");
        $stop; // 停止仿真
    end

endmodule