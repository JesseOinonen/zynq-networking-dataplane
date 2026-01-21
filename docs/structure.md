# Project structure

## fpga/
> Contains the programmable logic (pl) of the project that is made with SystemVerilog. It contains the rtl and tb

### rtl/axi/
> Files for axi rx/tx & axi_lite protocal.

### rtl/parser/
> Ethernet/IP/UDP/TCP parsers

### rtl/match_action
> Flow & decision making

### rtl/observability/
> Measurement IP that measures latency, throughput and errors

### rtl/common/
> Common packages, classes, constants etc.

### rtl/top/
> Top level & Zynq wrapper

## ps/
> Contains control plane program logic written in C
