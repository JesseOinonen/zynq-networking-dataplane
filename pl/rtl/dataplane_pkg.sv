package dataplane_pkg;
    // CSR word offsets (32-bit words)
    `define CSR_CTRL           4'h1   // 0x04
    // Flow key / parser status (read-only)
    `define DST_MAC_L      4'h2   // 0x08
    `define DST_MAC_H      4'h3   // 0x0C
    `define SRC_MAC_L      4'h4   // 0x10
    `define SRC_MAC_H      4'h5   // 0x14
    `define ETH_TYPE       4'h6   // 0x18
    `define SRC_IP         4'h7   // 0x1C
    `define DST_IP         4'h8   // 0x20
    `define SRC_PORT_DST   4'h9   // 0x24
endpackage