`timescale 1ns / 1ps

module cpu_tb;

    reg clock = 1'b0;
    reg reset = 1'b1;
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

    // Inside cpu
    wire [31:0] tb_pc     = dut.u_cpu.pc;
    wire [31:0] tb_imm    = dut.u_cpu.imm;
    wire [31:0] tb_src1   = dut.u_cpu.src1_rdata;
    wire [31:0] tb_src2   = dut.u_cpu.src2_rdata;
    wire [31:0] tb_alu_a  = dut.u_cpu.ALU_A;
    wire [31:0] tb_alu_b  = dut.u_cpu.ALU_B;
    wire [3:0]  tb_alu_op = dut.u_cpu.ALU_OP;

    // Signals in top module
    wire        tb_OF     = led[1];
    wire        tb_ZF     = led[0];
    wire [31:0] tb_inst_mem_spo = dut.inst_mem_spo;
    wire [31:0] tb_F            = dut.F;

    always #5 clock = ~clock;

    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;
    end

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end

    integer cycle;
    initial begin
        @(negedge clock);
        for (cycle = 0; cycle < 40; cycle = cycle + 1) begin
            @(posedge clock);
            #1;
            $display("Cycle %0d | PC=%h Inst=%h | src1=%h src2=%h | imm=%h | A=%h B=%h | F=%h | ALU_OP=%0h | ZF=%b OF=%b",
                     cycle, tb_pc, tb_inst_mem_spo, tb_src1, tb_src2, tb_imm, tb_alu_a, tb_alu_b, tb_F, tb_alu_op, tb_ZF, tb_OF);
        end
        $display("Simulation finished after %0d cycles.", cycle);
        $stop;
    end

endmodule
 
