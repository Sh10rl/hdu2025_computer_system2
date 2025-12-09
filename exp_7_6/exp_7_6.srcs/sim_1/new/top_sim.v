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
    wire [31:0] tb_pc         = uut.u_cpu.pc;
    wire [31:0] tb_inst       = uut.inst;
    wire [31:0] tb_alu_a      = uut.u_cpu.ALU_A;
    wire [31:0] tb_alu_b      = uut.u_cpu.ALU_B;
    wire [3:0]  tb_alu_op     = uut.u_cpu.ALU_OP;
    wire [31:0] tb_F          = uut.F;
    wire [31:0] tb_regs [0:31] = uut.u_cpu.u_regfile.registers;
    wire        tb_OF         = uut.u_cpu.OF;
    wire        tb_ZF         = uut.u_cpu.ZF;
    wire [31:0] tb_mem_wdata  = uut.u_cpu.src2_rdata; // data memory input (write data)
    wire [31:0] tb_mem_rdata  = uut.data_mem_spo;     // data memory output (read data)

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
        
        $dumpvars(0, tb_top.uut.u_cpu.pc, tb_top.uut.inst, tb_top.uut.u_cpu.ZF, tb_top.uut.u_cpu.OF);
        $dumpvars(0, tb_top.uut.u_cpu.ALU_A, tb_top.uut.u_cpu.ALU_B, tb_top.uut.F, tb_top.uut.u_cpu.ALU_OP);
        $dumpvars(0, tb_top.uut.u_cpu.pc_next_out, tb_top.uut.u_cpu.reg_wdata_out); 
        $dumpvars(0, tb_top.uut.u_cpu.u_decoder.is_beq, tb_top.uut.u_cpu.u_decoder.is_bne, tb_top.uut.u_cpu.u_decoder.is_jal, tb_top.uut.u_cpu.u_decoder.is_jalr);
        $dumpvars(0, tb_top.uut.u_cpu.u_regfile.registers[1], 
                     tb_top.uut.u_cpu.u_regfile.registers[10], 
                     tb_top.uut.u_cpu.u_regfile.registers[11], 
                     tb_top.uut.u_cpu.u_regfile.registers[12], 
                     tb_top.uut.u_cpu.u_regfile.registers[13]);
        
        $display("\n==============================================================================================================================");
        $display("| Cycle |    PC    | Instruction |    ALU_A      |    ALU_B      |    F      | OP | ZF OF |  Mem_Din   |  Mem_Dout  |");
        $display("==============================================================================================================================");
    end

    always @(posedge clock) begin
        if (reset) begin
            cycle <= 0;
        end else begin
            $display("|  %02d  | %8h |    %8h  | %10h | %10h | %10h | %1h  |  %b  %b | %10h | %10h |",
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
        
        // run long enough to cover program (400ns 足够覆盖所有测试指令)
        #400; 
        
        $display("=======================================================================================\n");
        $display("--- 寄存器验证 (x10-x13) ---");
        $display("x10 (成功标志): %h (Expected: 1)", tb_regs[10]);
        $display("x11 (成功标志): %h (Expected: 1)", tb_regs[11]);
        $display("x12 (函数内设置): %h (Expected: 1)", tb_regs[12]);
        $display("x13 (返回后设置): %h (Expected: 1)", tb_regs[13]);
        
        if(tb_regs[10] == 32'd1 && tb_regs[11] == 32'd1 && tb_regs[12] == 32'd1 && tb_regs[13] == 32'd1) begin
            $display("\n TEST PASSED: 所有控制流指令测试成功。");
        end else begin
            $display("\nTEST FAILED: 寄存器值不符合预期，测试失败！");
        end
        
        $stop; // 停止仿真
    end

endmodule