# Zynq Networking Dataplane

> FPGA-accelerated networking dataplane on the Arty Z7 (Zynq-7000 SoC), controlled by Linux running on the ARM PS.

## Overview

This project implements a hardware packet processing pipeline in the FPGA programmable logic (PL). The ARM processor (PS) configures flow rules and reads telemetry over AXI-Lite. Packet data flows through the PL pipeline at line rate without CPU involvement.

**Implemented:**
- AXI-Stream RX ingress with FIFO buffering
- 3-stage protocol parser: Ethernet → IPv4 → TCP/UDP
- 128-bit 5-tuple flow key generation (eth_type + src_ip + dst_ip + src_port + dst_port + protocol)
- Hash-based flow table with 1024 entries and XOR fold hash (full 128-bit coverage)
- Match-action engine with drop / forward / modify / trap / count actions
- AXI-Lite slave and CSR register file for PS control
- Observability modules: timestamp, latency monitor, throughput counter, error counter

**In progress / planned:**
- AXI-Stream TX egress (axi_tx stub present)
- action_stage packet data pass-through and header rewrite
- Elastic buffer before TX
- AXI DMA integration for PS ↔ DDR packet transfer
- AXI4-Stream width converter for DATA_WIDTH=256 operation

---

## Architecture

### Pipeline

```
MAC / PHY
    │  AXI-Stream (DATA_WIDTH bits)
    ▼
┌─────────┐
│  axi_rx │  FIFO ingress buffer (depth=256, almost-full backpressure)
└────┬────┘
     │
     ▼
┌────────────┐
│ eth_parser │  Extracts dst_mac, src_mac, eth_type — passes stream downstream
└─────┬──────┘
      │
      ▼
┌──────────────┐
│ ipv4_parser  │  Extracts src_ip, dst_ip, protocol, IHL — passes stream downstream
└──────┬───────┘
       │
       ▼
┌─────────────────┐
│ udp_tcp_parser  │  Extracts src_port, dst_port (and TCP fields) — passes stream downstream
└────────┬────────┘
         │
         ▼
┌──────────────┐
│ flow_key_gen │  Assembles 128-bit flow key from parsed fields, asserts valid_flow_key
└──────┬───────┘
       │ flow_key [127:0]
       ▼
┌────────────┐
│ flow_table │  Hash lookup → flow_hit + flow_id [9:0]. Passes AXI-Stream downstream.
└─────┬──────┘
      │ flow_hit, flow_id
      ▼
┌──────────────┐
│ action_stage │  Reads action_table[flow_id] → drop / forward / modify / trap / count
└──────────────┘
         │  (AXI-Stream TX output — in progress)
         ▼
      axi_tx
```

Each parser stage registers the incoming AXI-Stream and forwards it downstream with a 1-cycle latency, keeping data aligned with the ready signals generated in parallel.

### Flow Key Layout

```
[127:120]  8'h00         (reserved)
[119:104]  eth_type      16 bits
[103:72]   src_ip        32 bits
[71:40]    dst_ip        32 bits
[39:24]    src_port      16 bits
[23:8]     dst_port      16 bits
[7:0]      protocol       8 bits
```

### Flow Table

- 1024 entries, BRAM-backed
- Hash: XOR of all eight 16-bit slices of the 128-bit key, folded to 10 bits
- Each entry: `{valid, key[127:0], id[9:0]}`
- Hit requires exact key match (collision-safe)
- Programmed by PS via AXI-Lite (5 × 32-bit writes per entry)

### Action Table

- 1024 entries, BRAM-backed, indexed by `flow_id`
- Entry fields: `drop`, `forward`, `modify`, `out_port[3:0]`, `trap`, `count`, `valid`, `dst_mac[47:0]`, `src_mac[47:0]`
- Modify action requires 5 × 32-bit writes (flags + 3 MAC words)
- Programmed by PS via AXI-Lite

---

## AXI Address Map

Address bits `[31:30]` select the target:

| `ADDR[31:30]` | Target       | Index bits      |
|---------------|--------------|-----------------|
| `00`          | CSR          | full address    |
| `01`          | Action table | `ADDR[11:2]`    |
| `10`          | Flow table   | `ADDR[11:2]`    |

### CSR Register Map

| Offset | Name          | Access | Description                            |
|--------|---------------|--------|----------------------------------------|
| 0x04   | CTRL          | R/W    | Control register                       |
| 0x08   | DST_MAC_L     | R      | Destination MAC [31:0]                 |
| 0x0C   | DST_MAC_H     | R      | Destination MAC [47:32]                |
| 0x10   | SRC_MAC_L     | R      | Source MAC [31:0]                      |
| 0x14   | SRC_MAC_H     | R      | Source MAC [47:32]                     |
| 0x18   | ETH_TYPE      | R      | EtherType                              |
| 0x1C   | SRC_IP        | R      | Source IP                              |
| 0x20   | DST_IP        | R      | Destination IP                         |
| 0x24   | PROTOCOL      | R      | IP protocol (6=TCP, 17=UDP)            |
| 0x28   | UDP_PORT      | R      | [31:16] src port, [15:0] dst port      |
| 0x2C   | TCP_PORT      | R      | [31:16] src port, [15:0] dst port      |
| 0x30   | FLOW_KEY_32   | R      | flow_key [31:0]                        |
| 0x34   | FLOW_KEY_64   | R      | flow_key [63:32]                       |
| 0x38   | FLOW_KEY_96   | R      | flow_key [95:64]                       |
| 0x3C   | FLOW_KEY_128  | R      | flow_key [127:96]                      |

---

## Directory Structure

```
.
├── docs/
│   ├── specifications/
│   └── TODO.md
├── pl/
│   ├── rtl/
│   │   ├── axi/
│   │   │   ├── axi_rx.sv          # AXI-Stream RX FIFO
│   │   │   ├── axi_tx.sv          # AXI-Stream TX (stub)
│   │   │   ├── axi_lite_slave.sv  # AXI4-Lite slave interface
│   │   │   └── axi_addr_decode.sv # Write address decoder (CSR / flow / action)
│   │   ├── parser/
│   │   │   ├── eth_parser.sv
│   │   │   ├── ipv4_parser.sv
│   │   │   └── udp_tcp_parser.sv
│   │   ├── match_action/
│   │   │   ├── flow_key_gen.sv    # 128-bit flow key assembly
│   │   │   ├── flow_table.sv      # 1024-entry BRAM hash table
│   │   │   └── action_stage.sv    # Per-flow action execution
│   │   ├── observability/
│   │   │   ├── timestamp.sv
│   │   │   ├── latency_monitor.sv
│   │   │   ├── throughput_counter.sv
│   │   │   └── error_counter.sv
│   │   ├── top/
│   │   │   ├── dataplane_top.sv   # Full pipeline instantiation
│   │   │   └── zynq_wrapper.sv    # PS/PL integration (Vivado block design)
│   │   ├── csr.sv                 # Control and status registers
│   │   └── dataplane_pkg.sv       # Shared parameters and CSR offsets
│   └── tb/
│       ├── cases/                 # Per-module testcase packages
│       ├── top/                   # Testbench top, AXI interface, submodule wiring
│       └── verification_plan.md   # Verification checklist
├── ps/                            # ARM PS software (Linux driver / userspace)
├── vivado/                        # Vivado project and constraints
└── Makefile
```

---

## Parameters

| Parameter    | Default | Description                              |
|--------------|---------|------------------------------------------|
| `DATA_WIDTH` | 64      | AXI-Stream data bus width in bits. All parser and datapath modules scale with `DATA_WIDTH/8` byte iteration. Tested at 64; 256 supported with AXI width converter at PS boundary. |

---

## Platform

- **Board:** Digilent Arty Z7 (Zynq-7000, XC7Z020)
- **PS:** ARM Cortex-A9, running Linux
- **PL clock:** 125 MHz
- **RTL language:** SystemVerilog
- **Simulator:** Vivado xsim / ModelSim
