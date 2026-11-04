# 实验 7.4：运算类指令单周期 CPU

本目录是后续实验（7.5、7.6）的基础版本，重点完成运算类指令的数据通路与控制逻辑。

## 1. 本实验内容

- 打通单周期 CPU 基本通路：取指、译码、寄存器堆、ALU、写回。
- 实现 `add/sub/sll/slt/sltu/xor/or/and/addi/slli/slti/lui/auipc` 等运算类指令。
- 输出 `ZF`、`OF` 标志位，便于观测运算结果状态。

## 2. 目录与文件说明

- `exp_7_4.srcs/sources_1/new/`：手写 RTL 源码。
- `exp_7_4.srcs/sim_1/new/cpu_tb.v`：仿真 testbench。
- `exp_7_4.srcs/sources_1/imports/coe/Inst_ROM.coe`：指令 ROM 初始化文件。
- `exp_7_4.xpr`：Vivado 工程文件。
- `bit/top.bit`：本实验 bitstream 存放路径。
- `docs/`：本实验 RTL 图、电路图、波形图存放路径。

## 3. Bit 文件

- `bit` 文件用于将本实验逻辑下载到 FPGA。
- 由 `exp_7_4.xpr` 的 `impl_1` 运行 `write_bitstream` 生成。
- 建议将生成的 `top.bit` 复制到 `exp_7_4/bit/top.bit`。

## 4. RTL 图与电路图

- RTL 图：展示模块连接关系与数据通路。
- 电路图：展示综合/实现后的资源映射结果。
- 建议截图统一放入 `docs/`，命名为 `rtl.png`、`schematic.png`、`waveform.png`。

## 5. COE 文件含义

- `Inst_ROM.coe` 为指令存储器初始化内容。
- 每行 32 位十六进制数据对应一条机器指令。
- CPU 上电后从 `PC=0` 开始顺序取指执行。

## 6. 继承关系说明

- 7.4 是 7.5 与 7.6 的基础版本。
- 建议按 `7.4 -> 7.5 -> 7.6` 顺序查看完整叠加过程。
