`timescale 1ns / 1ps

module tb_top;

    // Inputs
    reg clock;
    reg board_clk;
    reg reset;
    reg [1:0] sw;

    // Outputs
    wire [1:0]  led;
    wire [2:0]  which;
    wire [7:0]  seg;
    wire        enable;

    // Internal probes, ordered like cpu_tb.v (4-17)
    wire [31:0] tb_pc        = uut.u_cpu.pc;
    wire [31:0] tb_inst      = uut.inst;
    wire [31:0] tb_alu_a     = uut.u_cpu.ALU_A;
    wire [31:0] tb_alu_b     = uut.u_cpu.ALU_B;
    wire [3:0]  tb_alu_op    = uut.u_cpu.ALU_OP;
    wire [31:0] tb_F         = uut.F;
    wire [31:0] tb_regs [0:31] = uut.u_cpu.u_regfile.registers;
    wire        tb_OF        = uut.u_cpu.OF;
    wire        tb_ZF        = uut.u_cpu.ZF;
    wire [31:0] tb_mem_wdata = uut.u_cpu.src2_rdata; // data memory input (write data)
    wire [31:0] tb_mem_rdata = uut.data_mem_spo;     // data memory output (read data)

    // Instantiate top module
    top uut (
        .clock(clock), 
        .reset(reset), 
        .sw(sw), 
        .board_clk(board_clk), 
        .led(led), 
        .which(which), 
        .seg(seg),
        .enable (enable)
    );

    // Clocks (10ns period)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        board_clk = 0;
        forever #5 board_clk = ~board_clk;
    end

    integer cycle;

    // --- Logging and waveform ---
    initial begin
        cycle = 0;
        $dumpfile("top_sim.vcd");
        $dumpvars(0, tb_top);
        $display("\n==============================================================================================================================");
        $display("| Cycle |    PC    | Instruction |     ALU_A     |     ALU_B     |     F      | OP | ZF OF |  Mem_Din   |  Mem_Dout  |");
        $display("==============================================================================================================================");
    end

    always @(posedge clock) begin
        if (reset) begin
            cycle <= 0;
        end else begin
            $display("|  %02d  | %8h |   %8h  | %10h | %10h | %10h | %1h  |  %b  %b | %10h | %10h |",
                     cycle, tb_pc, tb_inst, tb_alu_a, tb_alu_b, tb_F, tb_alu_op, tb_ZF, tb_OF,
                     tb_mem_wdata, tb_mem_rdata);
            cycle <= cycle + 1;
        end
    end
    // -----------------

    // Test sequence
    initial begin
        // init
        reset = 1;
        sw = 2'b00;
        #20; // hold reset 20ns
        
        reset = 0; // release reset
        
        // run long enough to cover program
        #150; 
        
        $display("=======================================================================================\n");
        $stop; // 停止仿真
    end

endmodule