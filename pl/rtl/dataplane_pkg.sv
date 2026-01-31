package dataplane_pkg;
    // CSR word offsets (32-bit words)
    `define CSR_CTRL       4'h1   // 0x04
    // Flow key / parser status (read-only)
    `define DST_MAC_L      4'h2   // 0x08
    `define DST_MAC_H      4'h3   // 0x0C
    `define SRC_MAC_L      4'h4   // 0x10
    `define SRC_MAC_H      4'h5   // 0x14
    `define ETH_TYPE       4'h6   // 0x18
    `define SRC_IP         4'h7   // 0x1C
    `define DST_IP         4'h8   // 0x20
    `define PROTOCOL       4'h9   // 0x24
    `define UDP_PORT       4'ha   // 0x28 [31:16] src port, [15:0] dst port
    `define TCP_PORT       4'hb   // 0x2C [31:16] src port, [15:0] dst port
    `define FLOW_KEY_32    4'hc   // 0x30 flow_key [31:0]
    `define FLOW_KEY_64    4'hd   // 0x34 flow_key [63:32]
    `define FLOW_KEY_96    4'he   // 0x38 flow_key [95:64]
    `define FLOW_KEY_128   4'hf   // 0x3C flow_key [127:96]
endpackage
