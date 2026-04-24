# TODO

## 1. AXI Width Converter IP (DATA_WIDTH=256)
- Add Xilinx AXI4-Stream Data Width Converter IP to Vivado block design
- Connect PL-internal 256-bit AXI-Stream → width converter → 64-bit PS HP port
- Same for TX direction: 64-bit → 256-bit before the dataplane pipeline
- Verify throughput improvement

## 2. AXI DMA IP
- Add Xilinx AXI DMA IP to Vivado block design (S2MM + MM2S)
- Connect PS M_AXI_GP0 → AXI DMA AXI-Lite (configuration control)
- Connect AXI DMA S_AXI_HP → PS HP0 (packet read/write to DDR)
- Connect action_stage AXI-Stream output → AXI DMA S2MM (RX: PL→DDR)
- Connect AXI DMA MM2S → axi_tx input (TX: DDR→PL)
- Connect AXI DMA interrupt → PS IRQ_F2P
- Write Linux driver / userspace library for DMA ring buffer management

## 3. Elastic buffer before axi_tx
- Add FIFO-based elastic buffer between action_stage output and axi_tx
- Purpose: absorb TX-side backpressure and smooth throughput bursts
- Size depth to at least max packet size / DATA_WIDTH beats (e.g. 1500B / 32B = ~48 → 64 entries minimum, 256 recommended)
- Add almost-full signal for upstream backpressure signaling

## 4. action_stage completion
- Add AXI-Stream packet data input (tdata, tkeep, tvalid, tlast) from udp_tcp_parser output
- Add AXI-Stream output for forward / modify / trap cases
- Implement drop gate: suppress output when action=DROP
- Implement modify action: overwrite dst_mac/src_mac in the packet header from action_table
- Implement trap action: redirect packet to PS (separate trap stream or out_port=CPU)
- Remove commented-out TODO lines and wire up actual outputs
- Connect action_stage output to elastic buffer (item 3) in dataplane_top
