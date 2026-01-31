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
    output logic [127:0]            flow_key,
    output logic                    valid_flow_key
);

logic        eth_captured;
logic        ipv4_captured;
logic        udp_tcp_captured;
logic        gen_flow_key;
logic [15:0] eth_type_capt;
logic [31:0] src_ip_capt;
logic [31:0] dst_ip_capt;
logic [ 7:0] protocol_capt;
logic [15:0] src_port_capt;
logic [15:0] dst_port_capt;

// Generate flow key once all of the parsers are finished and eth_type is IPv4
assign gen_flow_key = eth_captured && (eth_type_capt == 16'h0800) && ipv4_captured && udp_tcp_captured;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        eth_captured     <= 1'b0;
        ipv4_captured    <= 1'b0;
        udp_tcp_captured <= 1'b0;
        eth_type_capt    <= '0;
        src_ip_capt      <= '0;
        dst_ip_capt      <= '0;
        protocol_capt    <= '0;
        src_port_capt    <= '0;
        dst_port_capt    <= '0;
        valid_flow_key   <= 1'b0;
        flow_key         <= '0;
    end
    else begin
        valid_flow_key <= 1'b0;
        
        if (eth_captured && eth_type_capt != 16'h0800) begin
            eth_captured     <= 1'b0;
            ipv4_captured    <= 1'b0;
            udp_tcp_captured <= 1'b0;
        end

        if (eth_parser_ready && !eth_captured) begin
            eth_type_capt <= eth_type;
            eth_captured  <= 1'b1;
        end

        if (ipv4_parser_ready && !ipv4_captured) begin
            src_ip_capt   <= src_ip;
            dst_ip_capt   <= dst_ip;
            protocol_capt <= protocol;
            ipv4_captured <= 1'b1;
        end

        if (upd_tcp_parser_ready && !udp_tcp_captured) begin
            if (protocol_capt == 17) begin
                src_port_capt <= udp_src_port;
                dst_port_capt <= udp_dst_port;
            end
            else if (protocol_capt == 6) begin
                src_port_capt <= tcp_src_port;
                dst_port_capt <= tcp_dst_port;
            end
            udp_tcp_captured <= 1'b1;
        end

        if (gen_flow_key) begin
            flow_key = {24'h0,
                        src_ip_capt, 
                        dst_ip_capt, 
                        src_port_capt, 
                        dst_port_capt, 
                        protocol_capt};
            valid_flow_key   <= 1'b1;
            eth_captured     <= 1'b0;
            ipv4_captured    <= 1'b0;
            udp_tcp_captured <= 1'b0;
        end
    end
end

endmodule