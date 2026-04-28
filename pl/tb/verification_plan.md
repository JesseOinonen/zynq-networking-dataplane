# Verification Plan

# Consider adding SymbiYosys for formal verification

## axi_rx
- [ ] Minimum size packet (64 bytes)
- [ ] Maximum size packet (1500 bytes / jumbo)
- [ ] Back-to-back packets with no gap
- [ ] Multiple packets in pipeline simultaneously
- [ ] Partial / short packet (fewer valid tkeep bytes on last beat)
- [ ] Single-beat packet (tlast on first beat)
- [ ] Backpressure: out_tready deasserted mid-packet
- [ ] Backpressure: out_tready deasserted before packet starts
- [ ] FIFO almost-full: tready deasserted correctly before overflow
- [ ] FIFO full: no data is lost or corrupted
- [ ] Reset mid-packet: FIFO and state cleared correctly
- [ ] tvalid deasserted mid-packet (bubble in stream)
- [ ] sop asserted only on first beat of each packet
- [ ] in_packet tracks correctly across multi-beat packets

## eth_parser
- [ ] Correct dst_mac extraction
- [ ] Correct src_mac extraction
- [ ] Correct eth_type extraction (0x0800 IPv4)
- [ ] Correct eth_type extraction (non-IPv4, e.g. 0x0806 ARP)
- [ ] eth_parser_ready asserted exactly once per packet
- [ ] eth_parser_ready deasserted on next sop
- [ ] wcnt_eth correct value (bytes consumed from last beat)
- [ ] Multi-beat packet: header spans beat boundary
- [ ] Back-to-back packets: state resets correctly between packets
- [ ] Data pass-through: tdata/tkeep/tvalid/tlast forwarded unmodified (1-cycle delay)
- [ ] Reset mid-packet: outputs cleared

## ipv4_parser
- [ ] Correct src_ip extraction
- [ ] Correct dst_ip extraction
- [ ] Correct protocol extraction (6=TCP, 17=UDP)
- [ ] ipv4_parser_ready asserted exactly once per packet
- [ ] ipv4_parser_ready deasserted when eth_parser_ready deasserts
- [ ] wcnt_ipv4 correct value
- [ ] IHL=5 (20-byte header, no options)
- [ ] IHL>5 (header with options, up to 60 bytes)
- [ ] Non-IPv4 packet: ipv4_parser stays idle
- [ ] Header spans multiple beats
- [ ] Back-to-back packets: state resets correctly
- [ ] Data pass-through: tdata/tkeep/tvalid/tlast forwarded unmodified (1-cycle delay)
- [ ] Reset mid-packet: outputs cleared

## udp_tcp_parser
- [ ] Correct UDP src_port / dst_port / length / checksum extraction
- [ ] Correct TCP src_port / dst_port extraction
- [ ] Correct TCP seq_num / ack_num extraction
- [ ] Correct TCP flags / data_offset / window_size / checksum extraction
- [ ] udp_tcp_parser_ready asserted exactly once per packet
- [ ] udp_tcp_parser_ready deasserted on tlast
- [ ] UDP header spans beat boundary
- [ ] TCP header spans beat boundary
- [ ] Unknown protocol (not TCP/UDP): parser stays idle
- [ ] Back-to-back packets: state resets correctly
- [ ] Data pass-through: tdata/tkeep/tvalid/tlast forwarded unmodified (1-cycle delay)
- [ ] Reset mid-packet: outputs cleared

## flow_key_gen
- [ ] Correct 128-bit flow key assembly for UDP packet
- [ ] Correct 128-bit flow key assembly for TCP packet
- [ ] valid_flow_key asserted exactly once per packet
- [ ] valid_flow_key not asserted for non-IPv4 packets
- [ ] valid_flow_key not asserted for non-TCP/UDP protocols
- [ ] Correct eth_type included in key
- [ ] Correct src_ip, dst_ip, src_port, dst_port, protocol placement in key
- [ ] Capture flags reset correctly after key is emitted
- [ ] Back-to-back packets: key generated correctly for each
- [ ] Out-of-order ready signals: all three parser readys must arrive before key emits

## flow_table
- [ ] Write single entry via AXI-Lite (5-word sequence)
- [ ] Write all 1024 entries
- [ ] Read hit: flow_key matches stored entry, flow_hit=1, correct flow_id returned
- [ ] Read miss: flow_key does not match, flow_hit=0
- [ ] Hash collision: two keys map to same slot, only exact key match hits
- [ ] Entry with valid=0 does not produce a hit
- [ ] Overwrite existing entry with new key/id
- [ ] Write with incomplete sequence (< 5 words): entry not committed
- [ ] Back-to-back lookups: consecutive packets, independent hits/misses
- [ ] Reset: all entries cleared, no spurious hits
- [ ] AXI-Stream pass-through: tdata/tkeep/tvalid/tlast forwarded with correct timing
- [ ] wdone asserted for each accepted write word

## action_stage
- [ ] Write DROP action entry via AXI-Lite
- [ ] Write FORWARD action entry via AXI-Lite
- [ ] Write MODIFY action entry (5-word sequence incl. MACs) via AXI-Lite
- [ ] Write TRAP action entry via AXI-Lite
- [ ] Write COUNT action entry via AXI-Lite
- [ ] DROP: packet data suppressed on output when flow_hit + action=drop
- [ ] FORWARD: packet data forwarded unmodified on flow_hit
- [ ] MODIFY: dst_mac and src_mac replaced correctly in output stream
- [ ] TRAP: trap signal asserted on flow_hit
- [ ] No hit: default behavior (drop or pass-through, define expected)
- [ ] Invalid action entry (valid=0): no action taken
- [ ] Incomplete MODIFY write sequence: entry marked invalid
- [ ] Back-to-back packets with different actions
- [ ] wdone asserted correctly for each write word
- [ ] Reset: all entries cleared, outputs deasserted

## axi_lite_slave
- [ ] Single write transaction (AWVALID + WVALID)
- [ ] Single read transaction (ARVALID + RVALID)
- [ ] Write with AWVALID and WVALID arriving in different cycles
- [ ] Back-to-back write transactions
- [ ] Back-to-back read transactions
- [ ] BRESP = 0 (OKAY) on successful write
- [ ] RRESP = 0 (OKAY) on successful read
- [ ] waddr / wdata / we forwarded correctly to decode logic
- [ ] raddr / re forwarded correctly, rdata returned correctly
- [ ] Reset: handshake signals deasserted

## axi_addr_decode
- [ ] Write address in CSR range routed to we_csr
- [ ] Write address in flow table range routed to we_flow, correct waddr_flow (10-bit)
- [ ] Write address in action table range routed to we_act, correct waddr_act
- [ ] Mutually exclusive: only one we_* asserted per write
- [ ] wdone muxed correctly from the active target
- [ ] Read routed to CSR, rdata returned correctly
- [ ] rdone forwarded from CSR

## csr
- [ ] Read dst_mac register after eth_parser_ready
- [ ] Read src_mac register after eth_parser_ready
- [ ] Read eth_type register
- [ ] Read src_ip / dst_ip registers after ipv4_parser_ready
- [ ] Read protocol register
- [ ] Read UDP src_port / dst_port registers
- [ ] Read TCP src_port / dst_port registers
- [ ] Read flow_key register after valid_flow_key
- [ ] Read flow_key_valid status bit
- [ ] Write to CSR: wdone asserted
- [ ] Unknown address read: safe default (0 or defined value)
- [ ] Reset: all registers cleared

## axi_tx
- [ ] Basic packet transmission (tvalid/tdata/tkeep/tlast)
- [ ] Back-to-back packets
- [ ] Single-beat packet
- [ ] Backpressure from downstream: tready deasserted
- [ ] Reset mid-packet

## Observability
### timestamp
- [ ] Counter increments every clock cycle
- [ ] Reset sets counter to 0
- [ ] No overflow / wraparound issues at max value

### latency_monitor
- [ ] Latency measured correctly between start and end events
- [ ] Multiple concurrent measurements
- [ ] Reset clears state

### throughput_counter
- [ ] Byte/packet count increments correctly
- [ ] Count readable via CSR
- [ ] Reset clears counters

### error_counter
- [ ] Error events increment counter
- [ ] Counter saturates or wraps as designed
- [ ] Reset clears counter

## dataplane_top (integration)
- [ ] Full pipeline: IPv4/UDP packet produces correct flow_key
- [ ] Full pipeline: IPv4/TCP packet produces correct flow_key
- [ ] Flow table hit: correct action_stage lookup triggered
- [ ] Flow table miss: no spurious action
- [ ] AXI-Lite write to flow table entry visible to lookup logic
- [ ] AXI-Lite write to action table entry visible to action stage
- [ ] AXI-Lite read from CSR returns last parsed header fields
- [ ] Back-to-back packets through full pipeline
- [ ] Reset brings full pipeline to known idle state
- [ ] Non-IPv4 packet: pipeline handles gracefully (no hang)
