module flow_key_gen #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [15:0]             eth_type,
    input  logic                    eth_parser_ready,
    input  logic [31:0]             src_ip,
    input  logic [31:0]             dst_ip,
    input  logic [7:0]              protocol,
    input  logic                    ipv4_parser_ready,
    input  logic [15:0]             udp_src_port,
    input  logic [15:0]             udp_dst_port,
    input  logic [15:0]             tcp_src_port,
    input  logic [15:0]             tcp_dst_port,
    input  logic                    upd_tcp_parser_ready,
    output logic [95:0]             flow_key
);

// Should capture/lock parsed fields when ready signals are high

endmodule