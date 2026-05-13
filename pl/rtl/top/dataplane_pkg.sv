package dataplane_pkg;
    // CSR word offsets (32-bit words)
    localparam DP_CTRL     = 4'h1;   // 0x04
    // Flow key / parser status (read-only)
    localparam DST_MAC_L    = 4'h2;   // 0x08
    localparam DST_MAC_H    = 4'h3;   // 0x0C
    localparam SRC_MAC_L    = 4'h4;   // 0x10
    localparam SRC_MAC_H    = 4'h5;   // 0x14
    localparam ETH_TYPE     = 4'h6;   // 0x18
    localparam SRC_IP       = 4'h7;   // 0x1C
    localparam DST_IP       = 4'h8;   // 0x20
    localparam PROTOCOL     = 4'h9;   // 0x24
    localparam UDP_PORT     = 4'ha;   // 0x28 [31:16] src port, [15:0] dst port
    localparam TCP_PORT     = 4'hb;   // 0x2C [31:16] src port, [15:0] dst port
    localparam FLOW_KEY_32  = 4'hc;   // 0x30 flow_key [31:0]
    localparam FLOW_KEY_64  = 4'hd;   // 0x34 flow_key [63:32]
    localparam FLOW_KEY_96  = 4'he;   // 0x38 flow_key [95:64]
    localparam FLOW_KEY_128 = 4'hf;   // 0x3C flow_key [127:96]

endpackage
