// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Nov 19 11:58:21 2025
// Host        : LAPTOP-Shiori running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Hong_/Documents/Programming/VIVADO_Project/Experiment_7_4/Experiment_7_4.srcs/sources_1/ip/Inst_ROM/Inst_ROM_stub.v
// Design      : Inst_ROM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.1" *)
module Inst_ROM(a, spo)
/* synthesis syn_black_box black_box_pad_pin="a[7:0],spo[31:0]" */;
  input [7:0]a;
  output [31:0]spo;
endmodule
