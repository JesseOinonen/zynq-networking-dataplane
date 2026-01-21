# FPGA Dataplane RTL Architecture

> This directory contains the programmable logic (PL) dataplane implementation of the project, written in SystemVerilog.
The RTL implements a high-performance, modular, and observable networking dataplane, designed to be controlled by an ARM Processing System (PS) running Linux via AXI interfaces.

The architecture follows a clean separation of concerns between:

data movement
protocol parsing
decision making
observability
SoC-specific integration
High-Level Datapath Overview

The packet processing pipeline is organized as a linear, streaming datapath:


AXI-Stream RX
  → Protocol Parser
    → Match-Action Engine
      → Observability
        → AXI-Stream TX



Packet data flows through the pipeline using AXI-Stream.

Control and configuration are performed via AXI-Lite from the PS.

Each block is independently verifiable and reusable.

Directory Structure
```console
fpga/rtl/
├── axi/
├── parser/
├── match_action/
├── observability/
├── common/
└── top/
```

## rtl/axi/ – AXI Interfaces and Bus Logic

> This directory contains all AXI-related infrastructure.

### Responsibilities
AXI-Stream RX and TX interfaces
Backpressure handling (tvalid / tready)
FIFOs and buffering
AXI-Lite slave interface
Control and Status Register (CSR) decoding

### Purpose

> This layer abstracts AXI protocol details away from the datapath logic. All downstream modules operate on clean data and metadata interfaces without direct AXI dependencies.

This makes the dataplane:
easier to verify
easier to reuse
independent of SoC-specific AXI details

## rtl/parser/ – Protocol Parsing

> This directory implements protocol-aware packet parsing logic.

### Supported parsing stages (extensible)
Ethernet
IPv4 / IPv6
UDP
TCP

### Responsibilities

Extract protocol headers from incoming packets
Generate packet metadata (e.g. addresses, ports, protocol type)
Validate headers and track parsing state
Forward payload data downstream with associated metadata
Outputs
AXI-Stream packet payload
Structured metadata bus

The parser acts as the boundary between raw packets and semantic packet understanding, which is critical for scalable dataplane design.

## rtl/match_action/ – Match-Action Engine

> This directory contains the decision-making core of the dataplane.

### Responsibilities
Flow table lookups (e.g. CAM, TCAM, hash-based)
Policy evaluation based on packet metadata
Action generation:
forward
drop
modify headers
mark packets for statistics or tracing
Control Plane Interaction
Flow tables and policies are programmed by the PS via AXI-Lite
The dataplane remains fully autonomous once configured

This block is what transforms the design from a simple packet forwarder into a programmable network function (e.g. switch, firewall, load balancer).

## rtl/observability/ – Measurement and Telemetry

> This directory implements non-intrusive dataplane observability.

### Features
Packet and byte counters
Drop and error statistics
Latency measurement (RX → TX)
Debug and status registers

### Purpose
Observability is critical for:
performance validation
runtime monitoring
debugging and optimization

All metrics are accessible from the PS via AXI-Lite, and can be exposed to Linux user space or monitoring frameworks.

## rtl/common/ – Shared Definitions and Utilities

> This directory contains shared definitions used across the entire RTL codebase.

### Contents
Common typedef structures
Enumerations
Constants and parameters
Metadata and flow key definitions
Utility functions

### Purpose
This layer ensures:
consistent interfaces
scalable design
elimination of duplicated or conflicting definitions
All dataplane blocks depend on this directory.

## rtl/top/ – Top-Level Integration and Zynq Wrapper

> This directory contains the SoC-specific integration logic.

### Responsibilities
Top-level dataplane instantiation
AXI interconnect wiring
Zynq PS–PL integration
Clock and reset domain management
Address map definition
Interrupt routing (if enabled)

This is the only location where SoC-specific details appear.
All other RTL blocks are platform-agnostic and reusable.