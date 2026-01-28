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
`define CSR_SRC_PORT_DST   6'h24