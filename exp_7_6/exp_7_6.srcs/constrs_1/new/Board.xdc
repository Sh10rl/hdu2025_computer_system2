# 1. 开启比特流压缩
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# ============================================================================
# 时钟与复位信号 (使用按键模拟单步)
# ============================================================================
# board_clk: 20MHz 晶振，用于数码管扫描
set_property PACKAGE_PIN H4 [get_ports board_clk]
set_property IOSTANDARD LVCMOS18 [get_ports board_clk]

# clock: CPU 单步时钟 -> 映射到按键 swb[1] (Pin R4)
set_property PACKAGE_PIN R4 [get_ports clock]
set_property IOSTANDARD LVCMOS18 [get_ports clock]
# 因使用普通IO(按键)驱动时钟网络，需忽略专用路由检查
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clock_IBUF]

# reset: 复位信号 -> 映射到按键 swb[2] (Pin AA4)
set_property PACKAGE_PIN AA4 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]
# 为了防止复位信号作为时钟使能时的路由报错，建议也加上这句
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets reset_IBUF]


# ============================================================================
# 拨码开关 sw[1:0] (用于显示内容选择)
# ============================================================================
set_property PULLDOWN true [get_ports sw]
set_property IOSTANDARD LVCMOS18 [get_ports sw]

set_property PACKAGE_PIN AB7 [get_ports {sw[1]}]
set_property PACKAGE_PIN AB8 [get_ports {sw[0]}]


# ============================================================================
# LED灯 led[1:0] (用于显示 ZF, OF)
# ============================================================================
set_property IOSTANDARD LVCMOS18 [get_ports led]

set_property PACKAGE_PIN L4 [get_ports {led[1]}]
set_property PACKAGE_PIN J4 [get_ports {led[0]}]


# ============================================================================
# 数码管接口
# ============================================================================
# 1. 段选信号 seg[7:0] (DP, G, F, E, D, C, B, A)
set_property IOSTANDARD LVCMOS18 [get_ports seg]

set_property PACKAGE_PIN H19 [get_ports {seg[7]}]
set_property PACKAGE_PIN G20 [get_ports {seg[6]}]
set_property PACKAGE_PIN J22 [get_ports {seg[5]}]
set_property PACKAGE_PIN K22 [get_ports {seg[4]}]
set_property PACKAGE_PIN K21 [get_ports {seg[3]}]
set_property PACKAGE_PIN H20 [get_ports {seg[2]}]
set_property PACKAGE_PIN H22 [get_ports {seg[1]}]
set_property PACKAGE_PIN J21 [get_ports {seg[0]}]

# 2. 位选信号 which[2:0] (控制 3-8 译码器输入)
set_property IOSTANDARD LVCMOS18 [get_ports which]

set_property PACKAGE_PIN M22 [get_ports {which[2]}]
set_property PACKAGE_PIN M21 [get_ports {which[1]}]
set_property PACKAGE_PIN N22 [get_ports {which[0]}]

# 3. 数码管总使能 enable (控制 3-8 译码器使能端)
# 必须为高电平，数码管才会亮
set_property IOSTANDARD LVCMOS18 [get_ports enable]
set_property PACKAGE_PIN L21 [get_ports enable]

# 注意：如果你的 Top 模块没有 output enable 端口，请确保硬件连接逻辑正确。
# 板卡上的 L21 引脚 (3-8译码器使能) 如果不被驱动为高电平，数码管可能不亮。
# 建议检查代码中是否需要添加 enable 端口并将其约束到 L21。