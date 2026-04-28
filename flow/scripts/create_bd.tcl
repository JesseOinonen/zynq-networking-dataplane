create_bd_design "system"

# Unfinished

# PS
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7

# Ethernet
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:8.0 eth_mac

# AXI interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic

# Clocking
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz

# Reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_sys
