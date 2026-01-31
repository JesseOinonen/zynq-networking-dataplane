// CSR word offsets (32-bit words)
`define CSR_CTRL           6'h4

// Flow key / parser status (read-only)
`define CSR_DST_MAC_L      6'h8
`define CSR_DST_MAC_H      6'hC
`define CSR_SRC_MAC_L      6'h10
`define CSR_SRC_MAC_H      6'h14
`define CSR_ETH_TYPE       6'h18
`define CSR_SRC_IP         6'h1C
`define CSR_DST_IP         6'h20
`define CSR_PROTOCOL       6'h24
`define CSR_UDP_PORT       6'h28  // [31:16] src port, [15:0] dst port
`define CSR_TCP_PORT       6'h2C  // [31:16] src port, [15:0] dst port
`define CSR_FLOW_KEY_32    6'h30  // flow_key [31:0]
`define CSR_FLOW_KEY_64    6'h34  // flow_key [63:32]
`define CSR_FLOW_KEY_96    6'h38  // flow_key [95:64]
`define CSR_FLOW_KEY_128   6'h3C  // flow_key [127:96]
