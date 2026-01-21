# Zynq-7000 Hardware_accelerated Networking Dataplane

> Linux controlled, FPGA-accelerated networking dataplane with deterministic throughput and latency.

## Overview

This project implements a **hardware accelerated networking dataplane** on a Arty Z7 Zynq-7000 SoC

**Key Features:**
- **AXI-Stream datapath** with backpressure support
- Hardware packet parser (Ethernet / IPv4 / UDP / TCP)
- Match–action pipeline for flow-based processing
- Flow observability: latency, throughput, and error tracking
- Configurable via AXI-Lite control registers
- Zero-copy DMA between ARM PS and PL
- Modular design for reuse in networking, industrial, and low-latency applications