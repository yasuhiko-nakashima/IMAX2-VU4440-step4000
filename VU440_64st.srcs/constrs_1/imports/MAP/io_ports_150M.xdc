############################################################################
## Pin Constraints
############################################################################

set_property PACKAGE_PIN BD26    [get_ports {RESET}]
set_property IOSTANDARD LVCMOS18 [get_ports {RESET}]

set_property PACKAGE_PIN E48     [get_ports {EXT_RESET}]
set_property IOSTANDARD LVCMOS18 [get_ports {EXT_RESET}]
set_property PULLTYPE PULLUP     [get_ports {EXT_RESET}]

set_property PACKAGE_PIN K26     [get_ports {LED[0]}]
set_property PACKAGE_PIN T30     [get_ports {LED[1]}]
set_property PACKAGE_PIN R32     [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[*]}]

set_property PACKAGE_PIN AT49       [get_ports CLK_150M_CLK_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_150M_CLK_P]
set_property PACKAGE_PIN AU49       [get_ports CLK_150M_CLK_N]
set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_150M_CLK_N]

set_property PACKAGE_PIN BB26    [get_ports CLK_78M_CLK_P]
set_property IOSTANDARD LVDS     [get_ports CLK_78M_CLK_P]
set_property PACKAGE_PIN BB27    [get_ports CLK_78M_CLK_N]
set_property IOSTANDARD LVDS     [get_ports CLK_78M_CLK_N]


set_property PACKAGE_PIN BB10    [get_ports GT_DIFF_REFCLK0_CLK_P]
set_property PACKAGE_PIN BB9     [get_ports GT_DIFF_REFCLK0_CLK_N]
	
set_property PACKAGE_PIN BC8     [get_ports {GT_SERIAL_TX0_TXP[0]}]
set_property PACKAGE_PIN BC7     [get_ports {GT_SERIAL_TX0_TXN[0]}]
set_property PACKAGE_PIN BB6     [get_ports {GT_SERIAL_TX0_TXP[1]}]
set_property PACKAGE_PIN BB5     [get_ports {GT_SERIAL_TX0_TXN[1]}]
set_property PACKAGE_PIN BA8     [get_ports {GT_SERIAL_TX0_TXP[2]}]
set_property PACKAGE_PIN BA7     [get_ports {GT_SERIAL_TX0_TXN[2]}]
set_property PACKAGE_PIN AY6     [get_ports {GT_SERIAL_TX0_TXP[3]}]
set_property PACKAGE_PIN AY5     [get_ports {GT_SERIAL_TX0_TXN[3]}]
set_property PACKAGE_PIN AW8     [get_ports {GT_SERIAL_TX0_TXP[4]}]
set_property PACKAGE_PIN AW7     [get_ports {GT_SERIAL_TX0_TXN[4]}]
set_property PACKAGE_PIN AV6     [get_ports {GT_SERIAL_TX0_TXP[5]}]
set_property PACKAGE_PIN AV5     [get_ports {GT_SERIAL_TX0_TXN[5]}]
set_property PACKAGE_PIN AU8     [get_ports {GT_SERIAL_TX0_TXP[6]}]
set_property PACKAGE_PIN AU7     [get_ports {GT_SERIAL_TX0_TXN[6]}]
set_property PACKAGE_PIN AT6     [get_ports {GT_SERIAL_TX0_TXP[7]}]
set_property PACKAGE_PIN AT5     [get_ports {GT_SERIAL_TX0_TXN[7]}]

set_property PACKAGE_PIN BC4     [get_ports {GT_SERIAL_RX0_RXP[0]}]
set_property PACKAGE_PIN BC3     [get_ports {GT_SERIAL_RX0_RXN[0]}]
set_property PACKAGE_PIN BB2     [get_ports {GT_SERIAL_RX0_RXP[1]}]
set_property PACKAGE_PIN BB1     [get_ports {GT_SERIAL_RX0_RXN[1]}]
set_property PACKAGE_PIN BA4     [get_ports {GT_SERIAL_RX0_RXP[2]}]
set_property PACKAGE_PIN BA3     [get_ports {GT_SERIAL_RX0_RXN[2]}]
set_property PACKAGE_PIN AY2     [get_ports {GT_SERIAL_RX0_RXP[3]}]
set_property PACKAGE_PIN AY1     [get_ports {GT_SERIAL_RX0_RXN[3]}]
set_property PACKAGE_PIN AW4     [get_ports {GT_SERIAL_RX0_RXP[4]}]
set_property PACKAGE_PIN AW3     [get_ports {GT_SERIAL_RX0_RXN[4]}]
set_property PACKAGE_PIN AV2     [get_ports {GT_SERIAL_RX0_RXP[5]}]
set_property PACKAGE_PIN AV1     [get_ports {GT_SERIAL_RX0_RXN[5]}]
set_property PACKAGE_PIN AU4     [get_ports {GT_SERIAL_RX0_RXP[6]}]
set_property PACKAGE_PIN AU3     [get_ports {GT_SERIAL_RX0_RXN[6]}]
set_property PACKAGE_PIN AT2     [get_ports {GT_SERIAL_RX0_RXP[7]}]
set_property PACKAGE_PIN AT1     [get_ports {GT_SERIAL_RX0_RXN[7]}]


set_property PACKAGE_PIN M10     [get_ports GT_DIFF_REFCLK1_CLK_P]
set_property PACKAGE_PIN M9      [get_ports GT_DIFF_REFCLK1_CLK_N]

set_property PACKAGE_PIN R8      [get_ports {GT_SERIAL_TX1_TXP[0]}]
set_property PACKAGE_PIN R7      [get_ports {GT_SERIAL_TX1_TXN[0]}]
set_property PACKAGE_PIN P6      [get_ports {GT_SERIAL_TX1_TXP[1]}]
set_property PACKAGE_PIN P5      [get_ports {GT_SERIAL_TX1_TXN[1]}]
set_property PACKAGE_PIN N8      [get_ports {GT_SERIAL_TX1_TXP[2]}]
set_property PACKAGE_PIN N7      [get_ports {GT_SERIAL_TX1_TXN[2]}]
set_property PACKAGE_PIN M6      [get_ports {GT_SERIAL_TX1_TXP[3]}]
set_property PACKAGE_PIN M5      [get_ports {GT_SERIAL_TX1_TXN[3]}]
set_property PACKAGE_PIN W8      [get_ports {GT_SERIAL_TX1_TXP[4]}]
set_property PACKAGE_PIN W7      [get_ports {GT_SERIAL_TX1_TXN[4]}]
set_property PACKAGE_PIN V6      [get_ports {GT_SERIAL_TX1_TXP[5]}]
set_property PACKAGE_PIN V5      [get_ports {GT_SERIAL_TX1_TXN[5]}]
set_property PACKAGE_PIN U8      [get_ports {GT_SERIAL_TX1_TXP[6]}]
set_property PACKAGE_PIN U7      [get_ports {GT_SERIAL_TX1_TXN[6]}]
set_property PACKAGE_PIN T6      [get_ports {GT_SERIAL_TX1_TXP[7]}]
set_property PACKAGE_PIN T5      [get_ports {GT_SERIAL_TX1_TXN[7]}]

set_property PACKAGE_PIN R4      [get_ports {GT_SERIAL_RX1_RXP[0]}]
set_property PACKAGE_PIN R3      [get_ports {GT_SERIAL_RX1_RXN[0]}]
set_property PACKAGE_PIN P2      [get_ports {GT_SERIAL_RX1_RXP[1]}]
set_property PACKAGE_PIN P1      [get_ports {GT_SERIAL_RX1_RXN[1]}]
set_property PACKAGE_PIN N4      [get_ports {GT_SERIAL_RX1_RXP[2]}]
set_property PACKAGE_PIN N3      [get_ports {GT_SERIAL_RX1_RXN[2]}]
set_property PACKAGE_PIN M2      [get_ports {GT_SERIAL_RX1_RXP[3]}]
set_property PACKAGE_PIN M1      [get_ports {GT_SERIAL_RX1_RXN[3]}]
set_property PACKAGE_PIN W4      [get_ports {GT_SERIAL_RX1_RXP[4]}]
set_property PACKAGE_PIN W3      [get_ports {GT_SERIAL_RX1_RXN[4]}]
set_property PACKAGE_PIN V2      [get_ports {GT_SERIAL_RX1_RXP[5]}]
set_property PACKAGE_PIN V1      [get_ports {GT_SERIAL_RX1_RXN[5]}]
set_property PACKAGE_PIN U4      [get_ports {GT_SERIAL_RX1_RXP[6]}]
set_property PACKAGE_PIN U3      [get_ports {GT_SERIAL_RX1_RXN[6]}]
set_property PACKAGE_PIN T2      [get_ports {GT_SERIAL_RX1_RXP[7]}]
set_property PACKAGE_PIN T1      [get_ports {GT_SERIAL_RX1_RXN[7]}]



############################################################################
## Timing constraints
############################################################################
create_clock -period  6.400 -name REF_CLK0 [get_ports GT_DIFF_REFCLK0_CLK_P]
create_clock -period  6.400 -name REF_CLK1 [get_ports GT_DIFF_REFCLK1_CLK_P]
create_clock -period  6.666 -name AXI_CLK  [get_ports CLK_150M_CLK_P]
create_clock -period 12.800 -name INIT_CLK [get_ports CLK_78M_CLK_P]


set_max_delay -datapath_only -from [get_clocks AXI_CLK] -to [get_clocks aurora_64b66b_0_user_clk_out] 4.000
set_max_delay -datapath_only -from [get_clocks aurora_64b66b_0_user_clk_out] -to [get_clocks AXI_CLK] 2.000

set_max_delay -datapath_only -from [get_clocks AXI_CLK] -to [get_clocks aurora_64b66b_1_user_clk_out] 4.000
set_max_delay -datapath_only -from [get_clocks aurora_64b66b_1_user_clk_out] -to [get_clocks AXI_CLK] 2.000


set_max_delay -datapath_only -from [get_clocks AXI_CLK] -to [get_clocks INIT_CLK] 4.000
set_max_delay -datapath_only -from [get_clocks INIT_CLK] -to [get_clocks AXI_CLK] 2.000


set_max_delay -datapath_only -from [get_clocks INIT_CLK] -to [get_clocks rxoutclk_out[0]]   2.000
set_max_delay -datapath_only -from [get_clocks INIT_CLK] -to [get_clocks rxoutclk_out[0]_1] 2.000


set_max_delay -datapath_only -from [get_clocks INIT_CLK] -to [get_clocks aurora_64b66b_0_user_clk_out] 2.000
set_max_delay -datapath_only -from [get_clocks INIT_CLK] -to [get_clocks aurora_64b66b_1_user_clk_out] 2.000


###	set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/CPU_RESET_P]
###	set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/CPU_RESET_N]
set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/USER_RESET_P]
###	set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/USER_RESET_N]
set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/PERI_RESET_P]
set_false_path -through [get_pins inst_design_1_wrapper/design_1_i/RESET_CTRL_0/PERI_RESET_N]



