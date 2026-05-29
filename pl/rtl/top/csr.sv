import dataplane_pkg::*;

module csr (
    input  logic         clk,
    input  logic         rst,
    input  logic [31:0]  waddr,
    input  logic [31:0]  wdata,
    input  logic         we,
    input  logic [31:0]  raddr,
    input  logic         re,
    // Parser status inputs
    input  logic [47:0]  dst_mac,
    input  logic [47:0]  src_mac,
    input  logic [15:0]  eth_type,
    input  logic         eth_ready,
    input  logic         ipv4_ready,
    input  logic [31:0]  src_ip,
    input  logic [31:0]  dst_ip,
    input  logic [7:0]   protocol,
    input  logic         udp_tcp_ready,
    input  logic [15:0]  udp_src_port,
    input  logic [15:0]  udp_dst_port,
    input  logic [15:0]  tcp_src_port,
    input  logic [15:0]  tcp_dst_port,
    input  logic [127:0] flow_key,
    input  logic         flow_key_valid,
    // Observability inputs (live values, read directly — not stored in register_file)
    input  logic [63:0]  ts,
    input  logic [31:0]  latency_last,
    input  logic [31:0]  latency_min,
    input  logic [31:0]  latency_max,
    input  logic [31:0]  rx_bytes,
    input  logic [31:0]  rx_packets,
    input  logic [31:0]  tx_bytes,
    input  logic [31:0]  tx_packets,
    input  logic [31:0]  rx_overflow_count,
    input  logic [31:0]  flow_miss_count,
    input  logic [31:0]  drop_count,
    // Outputs
    output logic [31:0]  rdata,
    output logic         rdone,
    output logic         wdone,
    output logic         enable,
    output logic         loopback,
    output logic         flow_table_flush,
    output logic [1:0]   default_action,
    output logic [3:0]   irq_enable,
    output logic         stats_clear
);

// Register file — only writable/latched registers live here (parser status + DP_CTRL)
logic [31:0] register_file [0:15];

assign enable           = register_file[DP_CTRL][0];
assign loopback         = register_file[DP_CTRL][1];
assign flow_table_flush = register_file[DP_CTRL][2];
assign default_action   = register_file[DP_CTRL][4:3];
assign irq_enable       = register_file[DP_CTRL][8:5];
assign stats_clear      = register_file[DP_CTRL][9];

// Write logic
always_ff @(posedge clk) begin
    if (rst) begin
        register_file[DP_CTRL] <= '0;
        wdone <= 1'b0;
    end else begin
        register_file[DP_CTRL][2] <= 1'b0; // self-clear flow_table_flush
        register_file[DP_CTRL][9] <= 1'b0; // self-clear stats_clear
        wdone <= 1'b0;

        if (eth_ready) begin
            register_file[DST_MAC_L]  <= dst_mac[31:0];
            register_file[DST_MAC_H]  <= {16'b0, dst_mac[47:32]};
            register_file[SRC_MAC_L]  <= src_mac[31:0];
            register_file[SRC_MAC_H]  <= {16'b0, src_mac[47:32]};
            register_file[ETH_TYPE]   <= {16'b0, eth_type};
        end

        if (ipv4_ready) begin
            register_file[SRC_IP]     <= src_ip;
            register_file[DST_IP]     <= dst_ip;
            register_file[PROTOCOL]   <= {24'b0, protocol};
        end

        if (udp_tcp_ready) begin
            register_file[UDP_PORT]   <= {udp_src_port, udp_dst_port};
            register_file[TCP_PORT]   <= {tcp_src_port, tcp_dst_port};
        end

        if (flow_key_valid) begin
            register_file[FLOW_KEY_32]  <= flow_key[31:0];
            register_file[FLOW_KEY_64]  <= flow_key[63:32];
            register_file[FLOW_KEY_96]  <= flow_key[95:64];
            register_file[FLOW_KEY_128] <= flow_key[127:96];
        end

        if (we) begin
            case (waddr[5:2])
                4'(DP_CTRL): register_file[DP_CTRL] <= wdata;
                default: ;
            endcase
            wdone <= 1'b1;
        end
    end
end

// Read logic — parser/control from register_file, observability directly from inputs
always_ff @(posedge clk) begin
    if (rst) begin
        rdata <= '0;
        rdone <= 1'b0;
    end else begin
        rdone <= 1'b0;
        if (re) begin
            rdone <= 1'b1;
            case (raddr[6:2])
                // Control & parser status
                5'(DP_CTRL),
                5'(DST_MAC_L),
                5'(DST_MAC_H),
                5'(SRC_MAC_L),
                5'(SRC_MAC_H),
                5'(ETH_TYPE),
                5'(SRC_IP),
                5'(DST_IP),
                5'(PROTOCOL),
                5'(UDP_PORT),
                5'(TCP_PORT),
                5'(FLOW_KEY_32),
                5'(FLOW_KEY_64),
                5'(FLOW_KEY_96),
                5'(FLOW_KEY_128):   rdata <= register_file[raddr[5:2]];
                // Observability — live values
                5'(TS_LOW):          rdata <= ts[31:0];
                5'(TS_HIGH):         rdata <= ts[63:32];
                5'(LATENCY_LAST):    rdata <= latency_last;
                5'(LATENCY_MIN):     rdata <= latency_min;
                5'(LATENCY_MAX):     rdata <= latency_max;
                5'(RX_BYTES):        rdata <= rx_bytes;
                5'(RX_PACKETS):      rdata <= rx_packets;
                5'(TX_BYTES):        rdata <= tx_bytes;
                5'(TX_PACKETS):      rdata <= tx_packets;
                5'(RX_OVERFLOW_CNT): rdata <= rx_overflow_count;
                5'(FLOW_MISS_CNT):   rdata <= flow_miss_count;
                5'(DROP_CNT):        rdata <= drop_count;
                default:             rdata <= 32'hDEADBEEF;
            endcase
        end
    end
end

endmodule
