`timescale 1ns / 1ps

// 实验 7.4 顶层 CPU 测试平台。
// 每个周期打印一行关键信息，便于人工核对。
module cpu_tb;

    reg clock = 1'b0;
    reg reset = 1'b1;

    wire [31:0] tb_pc     = dut.u_cpu.pc;
    wire [31:0] tb_inst_mem_spo = dut.inst_mem_spo;
    wire [31:0] tb_alu_a  = dut.u_cpu.ALU_A;
    wire [31:0] tb_alu_b  = dut.u_cpu.ALU_B;
    wire [3:0]  tb_alu_op = dut.u_cpu.ALU_OP;
    wire [31:0] tb_F            = dut.F;
    wire        tb_OF     = dut.u_cpu.OF;
    wire        tb_ZF     = dut.u_cpu.ZF;
    wire [4:0] tb_waddr = dut.u_cpu.u_regfile.reg_waddr;
    wire [31:0] tb_regs [0:31]  = dut.u_cpu.u_regfile.registers;

/*
    wire [31:0] tb_imm    = dut.u_cpu.imm;
    wire [31:0] tb_src1   = dut.u_cpu.src1_rdata;
    wire [31:0] tb_src2   = dut.u_cpu.src2_rdata;
*/

    wire [1:0]  led;
    top dut (
        .clock        (clock),
        .reset        (reset),

        .swb       (1'b0), 
        .board_clk (1'b0), 
        .which     (),
        .seg       (),

        .led       (led)
    );

    // 仿真时钟：100 MHz（周期 10ns）。
    always #5 clock = ~clock;

    // 复位脉冲。
    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;
    end

    // 导出波形，便于在 GTKWave 中查看。
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end

    integer cycle;
    // 主监视循环。
    initial begin
        @(negedge clock);
        for (cycle = 0; cycle < 40;) begin
            @(posedge clock);
            cycle = cycle + 1;
            #1;
            $display("Cycle %0d | PC=%h Inst=%h | A=%h B=%h | F=%h | ALU_OP=%0h | ZF=%b OF=%b",
                     cycle, tb_pc, tb_inst_mem_spo, tb_alu_a, tb_alu_b, tb_F, tb_alu_op, tb_ZF, tb_OF);
        end
        $display("Simulation finished after %0d cycles.", cycle);
        $stop;
    end

endmodule
 
