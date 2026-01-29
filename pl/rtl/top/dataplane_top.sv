module dataplane_top #(
    parameter DATA_WIDTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,
    // AXI4-Lite interface
    input  logic [31:0] AWADDR,  
    input  logic [ 2:0] AWPROT,  
    input  logic        AWVALID, 
    output logic        AWREADY, 
    input  logic [31:0] WDATA,   
    input  logic [ 3:0] WSTRB,   
    input  logic        WVALID,  
    output logic        WREADY,  
    input  logic        BREADY,  
    output logic        BVALID,  
    output logic [ 1:0] BRESP,   
    input  logic [31:0] ARADDR,  
    input  logic [ 2:0] ARPROT,  
    input  logic        ARVALID, 
    output logic        ARREADY, 
    input  logic        RREADY,  
    output logic        RVALID,  
    output logic [31:0] RDATA,   
    output logic [ 1:0] RRESP,
    //AXI-Stream interface
    input  logic                    tvalid,
    input  logic [DATA_WIDTH-1:0]   tdata,
    input  logic [DATA_WIDTH/8-1:0] tkeep,
    input  logic                    tlast,
    output logic                    tready
);

logic [31:0] waddr_sig;
logic [31:0] wdata_sig;
logic        we_sig;
logic [31:0] raddr_sig;
logic        re_sig;
logic [31:0] rdata_sig;
logic        rdone_sig;
logic        wdone_sig;
logic        eth_parser_ready_sig;
logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_sig;
logic [DATA_WIDTH-1:0]   tdata_sig;
logic                    last_flag_sig;
logic                    data_valid_sig;
logic [DATA_WIDTH-1:0]   tdata_eth_sig;
logic                    data_valid_eth_sig;
logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_eth_sig;
logic                    last_flag_eth_sig;
logic [DATA_WIDTH-1:0]   tdata_ipv4_sig;
logic                    data_valid_ipv4_sig;
logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_ipv4_sig;
logic                    last_flag_ipv4_sig;
logic [47:0]             dst_mac_sig;
logic [47:0]             src_mac_sig;
logic [15:0]             eth_type_sig;
logic [31:0]             src_ip_sig;
logic [31:0]             dst_ip_sig;
logic [7:0]              protocol_sig;
logic                    ipv4_parser_ready_sig;
logic                    upd_tcp_parser_ready_sig;
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
logic [95:0]             flow_key_sig;
logic [3:0]              wcnt_eth_sig;
logic [4:0]              wcnt_ipv4_sig;

axi_lite_slave u_axi_lite_slave (
    .clk(clk),
    .rst_n(rst_n),
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

axi_rx #(.DATA_WIDTH(DATA_WIDTH)) u_axi_rx (
    .clk(clk),
    .rst_n(rst_n),
    .tvalid(tvalid),
    .tdata(tdata),
    .tkeep(tkeep),
    .tlast(tlast),
    .tready(tready),
    .idx(idx_sig),
    .tdata_out(tdata_sig),
    .data_valid(data_valid_sig),
    .last_flag(last_flag_sig)
);

csr u_csr (
    .clk(clk),
    .rst_n(rst_n),
    .waddr(waddr_sig), 
    .wdata(wdata_sig), 
    .we(we_sig),    
    .raddr(raddr_sig), 
    .re(re_sig),    
    .dst_mac(dst_mac_sig), 
    .src_mac(src_mac_sig), 
    .eth_type(eth_type_sig),
    .eth_ready(eth_parser_ready_sig),
    .ipv4_ready(ipv4_parser_ready_sig),
    .src_ip(src_ip_sig),
    .dst_ip(dst_ip_sig),
    .protocol(protocol_sig),
    .udp_tcp_ready(upd_tcp_parser_ready_sig),
    .udp_src_port(udp_src_port_sig),
    .udp_dst_port(udp_dst_port_sig),
    .tcp_src_port(tcp_src_port_sig),
    .tcp_dst_port(tcp_dst_port_sig),
    .rdata(rdata_sig), 
    .rdone(rdone_sig), 
    .wdone(wdone_sig)  
);

eth_parser #(.DATA_WIDTH(DATA_WIDTH)) u_eth_parser (
    .clk(clk),
    .rst_n(rst_n),
    .idx_in(idx_sig),
    .tdata_in(tdata_sig),
    .data_valid_in(data_valid_sig),
    .last_flag_in(last_flag_sig),
    .tdata_out(tdata_eth_sig),
    .idx_out(idx_eth_sig),
    .data_valid_out(data_valid_eth_sig),
    .last_flag_out(last_flag_eth_sig),
    .eth_parser_ready(eth_parser_ready_sig),
    .dst_mac(dst_mac_sig),
    .src_mac(src_mac_sig),
    .eth_type(eth_type_sig),
    .wcnt_eth(wcnt_eth_sig)
);

flow_key_gen #(.DATA_WIDTH(DATA_WIDTH)) u_flow_key_gen (
    .clk(clk),
    .rst_n(rst_n),
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
    .upd_tcp_parser_ready(upd_tcp_parser_ready_sig),
    .flow_key(flow_key_sig)
);

ipv4_parser #(.DATA_WIDTH(DATA_WIDTH)) u_ipv4_parser (
    .clk(clk),
    .rst_n(rst_n),
    .idx_in(idx_eth_sig),
    .tdata_in(tdata_eth_sig),
    .data_valid_in(data_valid_eth_sig),
    .eth_parser_ready(eth_parser_ready_sig),
    .last_flag_in(last_flag_eth_sig),
    .wcnt_eth(wcnt_eth_sig),
    .tdata_out(tdata_ipv4_sig),
    .idx_out(idx_ipv4_sig),
    .data_valid_out(data_valid_ipv4_sig),
    .last_flag_out(last_flag_ipv4_sig),
    .ipv4_parser_ready(ipv4_parser_ready_sig),
    .src_ip(src_ip_sig),
    .dst_ip(dst_ip_sig),
    .protocol(protocol_sig),
    .wcnt_ipv4(wcnt_ipv4_sig)
);

udp_tcp_parser #(.DATA_WIDTH(DATA_WIDTH)) u_udp_tcp_parser (
    .clk(clk),
    .rst_n(rst_n),
    .idx_in(idx_ipv4_sig),
    .last_flag_in(last_flag_ipv4_sig),
    .tdata_in(tdata_ipv4_sig),
    .data_valid_in(data_valid_ipv4_sig),
    .ipv4_parser_ready(ipv4_parser_ready_sig),
    .protocol(protocol_sig),
    .wcnt_ipv4(wcnt_ipv4_sig),
    .upd_tcp_parser_ready(upd_tcp_parser_ready_sig),
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
    .tcp_urgent_pointer(tcp_urgent_pointer_sig)
);

endmodule