module dataplane_top #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    // AXI4-Lite interface
    input  logic [31:0]             AWADDR,
    input  logic [ 2:0]             AWPROT,
    input  logic                    AWVALID,
    output logic                    AWREADY,
    input  logic [31:0]             WDATA,
    input  logic [ 3:0]             WSTRB,
    input  logic                    WVALID,
    output logic                    WREADY,
    input  logic                    BREADY,
    output logic                    BVALID,
    output logic [ 1:0]             BRESP,
    input  logic [31:0]             ARADDR,
    input  logic [ 2:0]             ARPROT,
    input  logic                    ARVALID,
    output logic                    ARREADY,
    input  logic                    RREADY,
    output logic                    RVALID,
    output logic [31:0]             RDATA,
    output logic [ 1:0]             RRESP,
    // AXI-Stream RX interface (from MAC/PHY)
    input  logic                    tvalid_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic [DATA_WIDTH/8-1:0] tkeep_in,
    input  logic                    tlast_in,
    output logic                    tready_out,
    // AXI-Stream TX interface (to MAC/PHY)
    output logic                    tvalid_out,
    output logic [DATA_WIDTH-1:0]   tdata_out,
    output logic [DATA_WIDTH/8-1:0] tkeep_out,
    output logic                    tlast_out,
    input  logic                    tready_mac,
    // AXI DMA MM2S input (PS → TX path)
    input  logic [DATA_WIDTH-1:0]   tdata_mm2s,
    input  logic                    tvalid_mm2s,
    input  logic [DATA_WIDTH/8-1:0] tkeep_mm2s,
    input  logic                    tlast_mm2s,
    output logic                    tready_mm2s,
    // AXI DMA S2MM output (trap → PS)
    output logic [DATA_WIDTH-1:0]   tdata_s2mm,
    output logic                    tvalid_s2mm,
    output logic [DATA_WIDTH/8-1:0] tkeep_s2mm,
    output logic                    tlast_s2mm,
    input  logic                    tready_s2mm
);

// ---------------------------------------------------------------------------
// AXI4-Lite internal signals
// ---------------------------------------------------------------------------
logic [31:0] waddr_sig;
logic [31:0] wdata_sig;
logic        we_sig;
logic [31:0] raddr_sig;
logic        re_sig;
logic [31:0] rdata_sig;
logic        rdone_sig;
logic        wdone_sig;

logic [31:0] waddr_csr_sig;
logic [31:0] wdata_csr_sig;
logic        we_csr_sig;
logic [31:0] raddr_csr_sig;
logic        re_csr_sig;
logic [31:0] rdata_csr_sig;
logic        rdone_csr_sig;
logic        wdone_csr_sig;

logic        wdone_flow_sig;
logic [9:0]  waddr_flow_sig;
logic [31:0] wdata_flow_sig;
logic        we_flow_sig;

logic        wdone_act_sig;
logic [9:0]  waddr_act_sig;
logic [31:0] wdata_act_sig;
logic        we_act_sig;

// ---------------------------------------------------------------------------
// CSR outputs
// ---------------------------------------------------------------------------
logic        enable;
logic        loopback;
logic        flow_table_flush_csr;
logic [1:0]  default_action_csr;
logic        irq_enable_csr;
logic        stats_clear_csr;

// ---------------------------------------------------------------------------
// RX FIFO outputs
// ---------------------------------------------------------------------------
logic                    rx_tvalid_sig;
logic [DATA_WIDTH-1:0]   rx_tdata_sig;
logic [DATA_WIDTH/8-1:0] rx_tkeep_sig;
logic                    rx_tlast_sig;
logic                    sop_sig;
logic                    in_packet_sig;

// ---------------------------------------------------------------------------
// Parser / flow pipeline internal signals
// ---------------------------------------------------------------------------
logic [47:0]             dst_mac_sig;
logic [47:0]             src_mac_sig;
logic [15:0]             eth_type_sig;
logic                    eth_parser_ready_sig;
logic [3:0]              wcnt_eth_sig;
logic                    in_packet_eth_sig;
logic                    sop_eth_sig;
logic [DATA_WIDTH-1:0]   tdata_eth_sig;
logic [DATA_WIDTH/8-1:0] tkeep_eth_sig;
logic                    tvalid_eth_sig;
logic                    tlast_eth_sig;

logic [31:0]             src_ip_sig;
logic [31:0]             dst_ip_sig;
logic [7:0]              protocol_sig;
logic                    ipv4_parser_ready_sig;
logic [4:0]              wcnt_ipv4_sig;
logic                    in_packet_ipv4_sig;
logic                    sop_ipv4_sig;
logic [DATA_WIDTH-1:0]   tdata_ipv4_sig;
logic [DATA_WIDTH/8-1:0] tkeep_ipv4_sig;
logic                    tvalid_ipv4_sig;
logic                    tlast_ipv4_sig;

logic [15:0]             udp_src_port_sig;
logic [15:0]             udp_dst_port_sig;
logic [15:0]             udp_length_sig;
logic [15:0]             udp_checksum_sig;
logic [15:0]             tcp_src_port_sig;
logic [15:0]             tcp_dst_port_sig;
logic [31:0]             tcp_seq_num_sig;
logic [31:0]             tcp_ack_num_sig;
logic [3:0]              tcp_data_offset_sig;
logic [5:0]              tcp_flags_sig;
logic [15:0]             tcp_window_size_sig;
logic [15:0]             tcp_checksum_sig;
logic [15:0]             tcp_urgent_pointer_sig;
logic                    udp_tcp_parser_ready_sig;
logic                    sop_udp_tcp_sig;
logic [DATA_WIDTH-1:0]   tdata_udp_tcp_sig;
logic [DATA_WIDTH/8-1:0] tkeep_udp_tcp_sig;
logic                    tvalid_udp_tcp_sig;
logic                    tlast_udp_tcp_sig;

logic [127:0]            flow_key_sig;
logic                    valid_flow_key_sig;
logic                    sop_flow_key_sig;
logic [DATA_WIDTH-1:0]   tdata_flow_key_sig;
logic [DATA_WIDTH/8-1:0] tkeep_flow_key_sig;
logic                    tvalid_flow_key_sig;
logic                    tlast_flow_key_sig;

logic                    flow_hit_sig;
logic [9:0]              flow_id_sig;
logic                    sop_flow_table_sig;
logic [DATA_WIDTH-1:0]   tdata_flow_table_sig;
logic [DATA_WIDTH/8-1:0] tkeep_flow_table_sig;
logic                    tvalid_flow_table_sig;
logic                    tlast_flow_table_sig;

// ---------------------------------------------------------------------------
// Action stage outputs
// ---------------------------------------------------------------------------
logic                    act_tvalid_sig;
logic [DATA_WIDTH-1:0]   act_tdata_sig;
logic [DATA_WIDTH/8-1:0] act_tkeep_sig;
logic                    act_tlast_sig;
logic                    trap_sig;

// ---------------------------------------------------------------------------
// TX path signals
// ---------------------------------------------------------------------------
// tready_tx = axis_mux.tready_dp: gates the entire PL pipeline.
// When DMA is being served (sel=1), tready_tx=0 freezes all PL stages and axi_rx drain.
logic                    tready_tx;

// Loopback mux: when loopback=1 the raw RX FIFO output feeds axis_mux directly,
// bypassing the parser/flow/action pipeline.
logic                    dp_tvalid_sig;
logic [DATA_WIDTH-1:0]   dp_tdata_sig;
logic [DATA_WIDTH/8-1:0] dp_tkeep_sig;
logic                    dp_tlast_sig;

assign dp_tvalid_sig = loopback ? rx_tvalid_sig : act_tvalid_sig;
assign dp_tdata_sig  = loopback ? rx_tdata_sig  : act_tdata_sig;
assign dp_tkeep_sig  = loopback ? rx_tkeep_sig  : act_tkeep_sig;
assign dp_tlast_sig  = loopback ? rx_tlast_sig  : act_tlast_sig;

logic                    tvalid_mux;
logic [DATA_WIDTH-1:0]   tdata_mux;
logic [DATA_WIDTH/8-1:0] tkeep_mux;
logic                    tlast_mux;
logic                    tready_mux;

// ---------------------------------------------------------------------------
// Trap / S2MM — placeholder until AXI DMA IP is connected in Vivado
// ---------------------------------------------------------------------------
assign tdata_s2mm  = '0;
assign tvalid_s2mm = 1'b0;
assign tkeep_s2mm  = '0;
assign tlast_s2mm  = 1'b0;

// Observability
logic [63:0] ts_sig;

// ---------------------------------------------------------------------------
// Module instantiations
// ---------------------------------------------------------------------------

axi_lite_slave u_axi_lite_slave (
    .clk(clk),
    .rst(rst),
    .AWADDR(AWADDR),
    .AWPROT(AWPROT),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WVALID(WVALID),
    .WREADY(WREADY),
    .BREADY(BREADY),
    .BVALID(BVALID),
    .BRESP(BRESP),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .RREADY(RREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .wdone(wdone_sig),
    .rdata(rdata_sig),
    .rdone(rdone_sig),
    .waddr(waddr_sig),
    .wdata(wdata_sig),
    .we(we_sig),
    .raddr(raddr_sig),
    .re(re_sig)
);

axi_addr_decode u_axi_addr_decode (
    .waddr(waddr_sig),
    .wdata(wdata_sig),
    .we(we_sig),
    .wdone_flow(wdone_flow_sig),
    .wdone_csr(wdone_csr_sig),
    .wdone_act(wdone_act_sig),
    .rdone_csr(rdone_csr_sig),
    .rdata_csr(rdata_csr_sig),
    .raddr(raddr_sig),
    .re(re_sig),
    .re_csr(re_csr_sig),
    .we_csr(we_csr_sig),
    .waddr_csr(waddr_csr_sig),
    .wdata_csr(wdata_csr_sig),
    .raddr_csr(raddr_csr_sig),
    .we_flow(we_flow_sig),
    .waddr_flow(waddr_flow_sig),
    .wdata_flow(wdata_flow_sig),
    .we_act(we_act_sig),
    .waddr_act(waddr_act_sig),
    .wdata_act(wdata_act_sig),
    .wdone(wdone_sig),
    .rdone(rdone_sig),
    .rdata(rdata_sig)
);

csr u_csr (
    .clk(clk),
    .rst(rst),
    .waddr(waddr_csr_sig),
    .wdata(wdata_csr_sig),
    .we(we_csr_sig),
    .raddr(raddr_csr_sig),
    .re(re_csr_sig),
    .dst_mac(dst_mac_sig),
    .src_mac(src_mac_sig),
    .eth_type(eth_type_sig),
    .eth_ready(eth_parser_ready_sig),
    .ipv4_ready(ipv4_parser_ready_sig),
    .src_ip(src_ip_sig),
    .dst_ip(dst_ip_sig),
    .protocol(protocol_sig),
    .udp_tcp_ready(udp_tcp_parser_ready_sig),
    .udp_src_port(udp_src_port_sig),
    .udp_dst_port(udp_dst_port_sig),
    .tcp_src_port(tcp_src_port_sig),
    .tcp_dst_port(tcp_dst_port_sig),
    .flow_key(flow_key_sig),
    .flow_key_valid(valid_flow_key_sig),
    .rdata(rdata_csr_sig),
    .rdone(rdone_csr_sig),
    .wdone(wdone_csr_sig),
    .enable(enable),
    .loopback(loopback),
    .flow_table_flush(flow_table_flush_csr),
    .default_action(default_action_csr),
    .irq_enable(irq_enable_csr),
    .stats_clear(stats_clear_csr)
);

// RX ingress FIFO — tready_tx freezes FIFO drain when pipeline is stalled
axi_rx #(.DATA_WIDTH(DATA_WIDTH)) u_axi_rx (
    .clk(clk),
    .rst(rst),
    .tvalid(tvalid_in),
    .tdata(tdata_in),
    .tkeep(tkeep_in),
    .tlast(tlast_in),
    .tready(tready_out),
    .out_tvalid(rx_tvalid_sig),
    .out_tdata(rx_tdata_sig),
    .out_tkeep(rx_tkeep_sig),
    .out_tlast(rx_tlast_sig),
    .out_tready(tready_tx),
    .sop(sop_sig),
    .in_packet(in_packet_sig),
    .enable(enable)
);

eth_parser #(.DATA_WIDTH(DATA_WIDTH)) u_eth_parser (
    .clk(clk),
    .rst(rst),
    .tready_in(tready_tx),
    .tkeep_in(rx_tkeep_sig),
    .tdata_in(rx_tdata_sig),
    .tvalid_in(rx_tvalid_sig),
    .tlast_in(rx_tlast_sig),
    .sop(sop_sig),
    .in_packet(in_packet_sig),
    .tdata_out(tdata_eth_sig),
    .tkeep_out(tkeep_eth_sig),
    .tvalid_out(tvalid_eth_sig),
    .tlast_out(tlast_eth_sig),
    .eth_parser_ready(eth_parser_ready_sig),
    .dst_mac(dst_mac_sig),
    .src_mac(src_mac_sig),
    .eth_type(eth_type_sig),
    .wcnt_eth(wcnt_eth_sig),
    .in_packet_out(in_packet_eth_sig),
    .sop_out(sop_eth_sig)
);

ipv4_parser #(.DATA_WIDTH(DATA_WIDTH)) u_ipv4_parser (
    .clk(clk),
    .rst(rst),
    .tkeep_in(tkeep_eth_sig),
    .tdata_in(tdata_eth_sig),
    .tvalid_in(tvalid_eth_sig),
    .eth_parser_ready(eth_parser_ready_sig),
    .tlast_in(tlast_eth_sig),
    .wcnt_eth(wcnt_eth_sig),
    .in_packet(in_packet_eth_sig),
    .sop_in(sop_eth_sig),
    .tready_in(tready_tx),
    .tdata_out(tdata_ipv4_sig),
    .tkeep_out(tkeep_ipv4_sig),
    .tvalid_out(tvalid_ipv4_sig),
    .tlast_out(tlast_ipv4_sig),
    .ipv4_parser_ready(ipv4_parser_ready_sig),
    .src_ip(src_ip_sig),
    .dst_ip(dst_ip_sig),
    .protocol(protocol_sig),
    .wcnt_ipv4(wcnt_ipv4_sig),
    .in_packet_out(in_packet_ipv4_sig),
    .sop_out(sop_ipv4_sig)
);

udp_tcp_parser #(.DATA_WIDTH(DATA_WIDTH)) u_udp_tcp_parser (
    .clk(clk),
    .rst(rst),
    .tkeep_in(tkeep_ipv4_sig),
    .tlast_in(tlast_ipv4_sig),
    .tdata_in(tdata_ipv4_sig),
    .tvalid_in(tvalid_ipv4_sig),
    .ipv4_parser_ready(ipv4_parser_ready_sig),
    .protocol(protocol_sig),
    .wcnt_ipv4(wcnt_ipv4_sig),
    .in_packet(in_packet_ipv4_sig),
    .sop_in(sop_ipv4_sig),
    .udp_tcp_parser_ready(udp_tcp_parser_ready_sig),
    .udp_src_port(udp_src_port_sig),
    .udp_dst_port(udp_dst_port_sig),
    .udp_length(udp_length_sig),
    .udp_checksum(udp_checksum_sig),
    .tcp_src_port(tcp_src_port_sig),
    .tcp_dst_port(tcp_dst_port_sig),
    .tcp_seq_num(tcp_seq_num_sig),
    .tcp_ack_num(tcp_ack_num_sig),
    .tcp_data_offset(tcp_data_offset_sig),
    .tcp_flags(tcp_flags_sig),
    .tcp_window_size(tcp_window_size_sig),
    .tcp_checksum(tcp_checksum_sig),
    .tcp_urgent_pointer(tcp_urgent_pointer_sig),
    .sop_out(sop_udp_tcp_sig),
    .tready_in(tready_tx),
    .tvalid_out(tvalid_udp_tcp_sig),
    .tdata_out(tdata_udp_tcp_sig),
    .tkeep_out(tkeep_udp_tcp_sig),
    .tlast_out(tlast_udp_tcp_sig)
);

flow_key_gen u_flow_key_gen (
    .clk(clk),
    .rst(rst),
    .eth_type(eth_type_sig),
    .eth_parser_ready(eth_parser_ready_sig),
    .src_ip(src_ip_sig),
    .dst_ip(dst_ip_sig),
    .protocol(protocol_sig),
    .ipv4_parser_ready(ipv4_parser_ready_sig),
    .udp_src_port(udp_src_port_sig),
    .udp_dst_port(udp_dst_port_sig),
    .tcp_src_port(tcp_src_port_sig),
    .tcp_dst_port(tcp_dst_port_sig),
    .udp_tcp_parser_ready(udp_tcp_parser_ready_sig),
    .flow_key(flow_key_sig),
    .valid_flow_key(valid_flow_key_sig),
    .tvalid_in(tvalid_udp_tcp_sig),
    .tdata_in(tdata_udp_tcp_sig),
    .tkeep_in(tkeep_udp_tcp_sig),
    .tlast_in(tlast_udp_tcp_sig),
    .tready_in(tready_tx),
    .tvalid_out(tvalid_flow_key_sig),
    .tdata_out(tdata_flow_key_sig),
    .tkeep_out(tkeep_flow_key_sig),
    .tlast_out(tlast_flow_key_sig),
    .sop_in(sop_udp_tcp_sig),
    .sop_out(sop_flow_key_sig)
);

flow_table u_flow_table (
    .clk(clk),
    .rst(rst),
    .flow_key(flow_key_sig),
    .flow_key_valid(valid_flow_key_sig),
    .waddr(waddr_flow_sig),
    .wdata(wdata_flow_sig),
    .we(we_flow_sig),
    .flow_hit(flow_hit_sig),
    .flow_id(flow_id_sig),
    .wdone(wdone_flow_sig),
    .flush(flow_table_flush_csr),
    .tvalid_in(tvalid_flow_key_sig),
    .tdata_in(tdata_flow_key_sig),
    .tkeep_in(tkeep_flow_key_sig),
    .tlast_in(tlast_flow_key_sig),
    .tready_in(tready_tx),
    .tvalid_out(tvalid_flow_table_sig),
    .tdata_out(tdata_flow_table_sig),
    .tkeep_out(tkeep_flow_table_sig),
    .tlast_out(tlast_flow_table_sig),
    .sop_in(sop_flow_key_sig),
    .sop_out(sop_flow_table_sig)
);

action_stage #(.DATA_WIDTH(DATA_WIDTH)) u_action_stage (
    .clk(clk),
    .rst(rst),
    .flow_hit(flow_hit_sig),
    .flow_id(flow_id_sig),
    .waddr(waddr_act_sig),
    .wdata(wdata_act_sig),
    .we(we_act_sig),
    .wdone(wdone_act_sig),
    .sop_in(sop_flow_table_sig),
    .tvalid_in(tvalid_flow_table_sig),
    .tdata_in(tdata_flow_table_sig),
    .tkeep_in(tkeep_flow_table_sig),
    .tlast_in(tlast_flow_table_sig),
    .tready_in(tready_tx),
    .tvalid_out(act_tvalid_sig),
    .tdata_out(act_tdata_sig),
    .tkeep_out(act_tkeep_sig),
    .tlast_out(act_tlast_sig),
    .trap(trap_sig)
);

// TX MUX: arbitrates between PL dataplane (dp_*) and PS DMA MM2S.
// tready_dp feeds back as tready_tx — the single pipeline freeze signal.
axis_mux #(.DATA_WIDTH(DATA_WIDTH)) u_axis_mux (
    .clk(clk),
    .rst(rst),
    .tvalid_dp(dp_tvalid_sig),
    .tdata_dp(dp_tdata_sig),
    .tkeep_dp(dp_tkeep_sig),
    .tlast_dp(dp_tlast_sig),
    .tready_dp(tready_tx),
    .tvalid_dma(tvalid_mm2s),
    .tdata_dma(tdata_mm2s),
    .tkeep_dma(tkeep_mm2s),
    .tlast_dma(tlast_mm2s),
    .tready_dma(tready_mm2s),
    .tready(tready_mux),
    .tvalid(tvalid_mux),
    .tdata(tdata_mux),
    .tkeep(tkeep_mux),
    .tlast(tlast_mux)
);

// TX egress: one registered stage, propagates MAC backpressure combinationally
axi_tx #(.DATA_WIDTH(DATA_WIDTH)) u_axi_tx (
    .clk(clk),
    .rst(rst),
    .tvalid_mux(tvalid_mux),
    .tdata_mux(tdata_mux),
    .tkeep_mux(tkeep_mux),
    .tlast_mux(tlast_mux),
    .tready_mux(tready_mux),
    .tready_in(tready_mac),
    .tvalid_out(tvalid_out),
    .tdata_out(tdata_out),
    .tkeep_out(tkeep_out),
    .tlast_out(tlast_out)
);

timestamp u_timestamp (
    .clk(clk),
    .rst(rst),
    .ts(ts_sig)
);

endmodule
