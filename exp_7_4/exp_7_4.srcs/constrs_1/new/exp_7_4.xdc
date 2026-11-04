# 开启 bitstream 压缩
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# 时钟与复位
set_property PACKAGE_PIN H4 [get_ports board_clk]
set_property IOSTANDARD LVCMOS18 [get_ports board_clk]

set_property PACKAGE_PIN R4 [get_ports clock]
set_property IOSTANDARD LVCMOS18 [get_ports clock]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clock_IBUF]

set_property PACKAGE_PIN AA4 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets reset_IBUF]

# 显示切换开关 swb
set_property PACKAGE_PIN AB8 [get_ports swb]
set_property IOSTANDARD LVCMOS18 [get_ports swb]
set_property PULLDOWN true [get_ports swb]

# LED
set_property IOSTANDARD LVCMOS18 [get_ports led]
set_property PACKAGE_PIN L4 [get_ports {led[1]}]
set_property PACKAGE_PIN J4 [get_ports {led[0]}]

# 数码管段选 seg[7:0]
set_property IOSTANDARD LVCMOS18 [get_ports seg]
set_property PACKAGE_PIN H19 [get_ports {seg[7]}]
set_property PACKAGE_PIN G20 [get_ports {seg[6]}]
set_property PACKAGE_PIN J22 [get_ports {seg[5]}]
set_property PACKAGE_PIN K22 [get_ports {seg[4]}]
set_property PACKAGE_PIN K21 [get_ports {seg[3]}]
set_property PACKAGE_PIN H20 [get_ports {seg[2]}]
set_property PACKAGE_PIN H22 [get_ports {seg[1]}]
set_property PACKAGE_PIN J21 [get_ports {seg[0]}]

# 数码管位选 which[2:0]
set_property IOSTANDARD LVCMOS18 [get_ports which]
set_property PACKAGE_PIN M22 [get_ports {which[2]}]
set_property PACKAGE_PIN M21 [get_ports {which[1]}]
set_property PACKAGE_PIN N22 [get_ports {which[0]}]
