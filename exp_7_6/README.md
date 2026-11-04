# 实验 7.6：在 7.5 基础上加入分支与跳转控制流

本目录是对 `exp_7_5` 的增量扩展，重点实现 `beq/bne/jal/jalr`。

## 1. 本实验新增内容（相对 7.5）

- 译码器新增控制流识别：`is_beq/is_bne/is_jal/is_jalr`。
- 取指单元新增 PC 更新选择：顺序执行、分支跳转、`jal`、`jalr`。
- 写回路径新增链接寄存器写回（`pc + 4`）。
- 顶层新增显示信号：`pc_next_out`、`reg_waddr_out`、`reg_wdata_out`。

## 2. 目录与文件说明

- `exp_7_6.srcs/sources_1/new/`：手写 RTL 源码。
- `exp_7_6.srcs/sim_1/new/top_sim.v`：仿真 testbench。
- `Inst_ROM.coe`：控制流测试程序机器码。
- `Data_RAM.coe`：数据 RAM 初始化内容。
- `bit/top.bit`：本实验 bitstream 预留路径。
- `docs/`：本实验 RTL/电路图存放目录。

## 3. Bit 文件

- `bit` 文件用于将本实验逻辑下载到 FPGA。
- 本实验 bit 文件规范路径：`exp_7_6/bit/top.bit`。
- 若尚未生成，请在 Vivado 中运行实现并导出 bitstream 后复制到该路径。

## 4. RTL 图与电路图

- RTL 图：重点查看 PC 更新相关多路选择与控制流信号。
- 电路图：重点查看控制逻辑综合后资源映射。
- 建议保存带时间戳截图，便于复核版本。

## 5. COE 文件含义

- `Inst_ROM.coe`：用于验证跳转/分支正确性的测试程序。
- `Data_RAM.coe`：可复用 7.5 的数据初始化，验证访存不被破坏。

## 6. 继承关系说明

- 7.6 保留 7.5 的访存能力，在此基础上新增控制流。
- 可按 7.4 -> 7.5 -> 7.6 顺序看到完整叠加过程。
