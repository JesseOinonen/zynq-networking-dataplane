package dataplane_pkg;
    // CSR word indices used with raddr[6:2] / waddr[6:2] (5-bit, 32 slots)
    // Addresses: index * 4 bytes

    // Control (R/W)
    localparam int DP_CTRL      = 1;   // 0x04

    // Parser status (R only, updated on each parsed header)
    localparam int DST_MAC_L    = 2;   // 0x08
    localparam int DST_MAC_H    = 3;   // 0x0C
    localparam int SRC_MAC_L    = 4;   // 0x10
    localparam int SRC_MAC_H    = 5;   // 0x14
    localparam int ETH_TYPE     = 6;   // 0x18
    localparam int SRC_IP       = 7;   // 0x1C
    localparam int DST_IP       = 8;   // 0x20
    localparam int PROTOCOL     = 9;   // 0x24
    localparam int UDP_PORT     = 10;  // 0x28  [31:16] src, [15:0] dst
    localparam int TCP_PORT     = 11;  // 0x2C  [31:16] src, [15:0] dst
    localparam int FLOW_KEY_32  = 12;  // 0x30  flow_key[31:0]
    localparam int FLOW_KEY_64  = 13;  // 0x34  flow_key[63:32]
    localparam int FLOW_KEY_96  = 14;  // 0x38  flow_key[95:64]
    localparam int FLOW_KEY_128 = 15;  // 0x3C  flow_key[127:96]

    // Observability (R only, live values from observability modules)
    localparam int TS_LOW           = 16;  // 0x40  timestamp[31:0]
    localparam int TS_HIGH          = 17;  // 0x44  timestamp[63:32]
    localparam int LATENCY_LAST     = 18;  // 0x48  last packet latency (cycles)
    localparam int LATENCY_MIN      = 19;  // 0x4C  min latency seen
    localparam int LATENCY_MAX      = 20;  // 0x50  max latency seen
    localparam int RX_BYTES         = 21;  // 0x54  RX bytes in last window
    localparam int RX_PACKETS       = 22;  // 0x58  RX packets in last window
    localparam int TX_BYTES         = 23;  // 0x5C  TX bytes in last window
    localparam int TX_PACKETS       = 24;  // 0x60  TX packets in last window
    localparam int RX_OVERFLOW_CNT  = 25;  // 0x64  RX FIFO overflow count
    localparam int FLOW_MISS_CNT    = 26;  // 0x68  flow table miss count
    localparam int DROP_CNT         = 27;  // 0x6C  drop action count

endpackage
