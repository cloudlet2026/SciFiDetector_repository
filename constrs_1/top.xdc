# AD9238 引脚约束，对应开发板扩展口J21
set_property PACKAGE_PIN J16 [get_ports adc_clk]
set_property PACKAGE_PIN F16 [get_ports {adc_data[1]}]
set_property PACKAGE_PIN F17 [get_ports {adc_data[0]}]
set_property PACKAGE_PIN H20 [get_ports {adc_data[3]}]
set_property PACKAGE_PIN J20 [get_ports {adc_data[2]}]
set_property PACKAGE_PIN G18 [get_ports {adc_data[5]}]
set_property PACKAGE_PIN G17 [get_ports {adc_data[4]}]
set_property PACKAGE_PIN H17 [get_ports {adc_data[7]}]
set_property PACKAGE_PIN H16 [get_ports {adc_data[6]}]
set_property PACKAGE_PIN G15 [get_ports {adc_data[9]}]
set_property PACKAGE_PIN H15 [get_ports {adc_data[8]}]
set_property PACKAGE_PIN K18 [get_ports {adc_data[11]}]
set_property PACKAGE_PIN K17 [get_ports {adc_data[10]}]

set_property IOSTANDARD LVCMOS33 [get_ports adc_clk]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data[*]}]

# 多路复用器模块的引脚约束，对应开发板扩展口J20的21-39脚
# 21、23、25、27、29、31、33、35脚：cmp_in[0]-cmp_in[7]
set_property PACKAGE_PIN V16 [get_ports {cmp_in[0]}]
set_property PACKAGE_PIN R18 [get_ports {cmp_in[1]}]
set_property PACKAGE_PIN W19 [get_ports {cmp_in[2]}]
set_property PACKAGE_PIN W20 [get_ports {cmp_in[3]}]
set_property PACKAGE_PIN P20 [get_ports {cmp_in[4]}]
set_property PACKAGE_PIN U17 [get_ports {cmp_in[5]}]
set_property PACKAGE_PIN U20 [get_ports {cmp_in[6]}]
set_property PACKAGE_PIN V15 [get_ports {cmp_in[7]}]
# 22、24、26、28脚：mux_sel[0] mux_sel_en mux_sel_en[2] mux_sel[1]
set_property PACKAGE_PIN W16 [get_ports {mux_sel[0]}]
set_property PACKAGE_PIN T17 [get_ports mux_sel_en]
set_property PACKAGE_PIN W18 [get_ports {mux_sel[2]}]
set_property PACKAGE_PIN V20 [get_ports {mux_sel[1]}]
# 多路复用器模块的IO标准设置
set_property IOSTANDARD LVCMOS33 [get_ports {cmp_in[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mux_sel[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports mux_sel_en]



set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_1]
set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_0]
