## Clock signal
set_property PACKAGE_PIN H16 [get_ports clk125]
set_property IOSTANDARD LVCMOS33 [get_ports clk125]
create_clock -name clk125 -period 8.0 [get_ports clk125]