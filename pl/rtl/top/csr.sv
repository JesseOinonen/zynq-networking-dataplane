import dataplane_pkg::*;

module csr (
    input  logic         clk,
    input  logic         rst,
    input  logic [31:0]  waddr,      // Write address
    input  logic [31:0]  wdata,      // Write data
    input  logic         we,         // Write enable
    input  logic [31:0]  raddr,      // Read address
    input  logic         re,         // Read enable
    input  logic [47:0]  dst_mac,    // Destination MAC from parser
    input  logic [47:0]  src_mac,    // Source MAC from parser
    input  logic [15:0]  eth_type,   // Ethertype from parser
    input  logic         eth_ready,  // Indicates new Ethernet frame parsed
    input  logic         ipv4_ready, // Indicates new IPv4 header parsed
    input  logic [31:0]  src_ip,     // Source IP from parser
    input  logic [31:0]  dst_ip,     // Destination IP from parser
    input  logic [7:0]   protocol,   // Protocol from parser
    input  logic         udp_tcp_ready,
    input  logic [15:0]  udp_src_port,
    input  logic [15:0]  udp_dst_port,
    input  logic [15:0]  tcp_src_port,
    input  logic [15:0]  tcp_dst_port,
    input  logic [127:0] flow_key,
    input  logic         flow_key_valid,
    output logic [31:0]  rdata,            // Read data
    output logic         rdone,            // Read done
    output logic         wdone,            // Write done
    output logic         enable,           // Enable dataplane
    output logic         loopback,         // Send packets back to sender w/o processing
    output logic         flow_table_flush, // Flush the whole flow table
    output logic [1:0]   default_action,   // Default action for dataplane
    output logic [3:0]   irq_enable,       // Enable interrupts
    output logic         stats_clear       // Clear packet counters
);

logic [31:0] register_file [0:15];

// Dataplane control signals
assign enable           = register_file[DP_CTRL][0];
assign loopback         = register_file[DP_CTRL][1];
assign flow_table_flush = register_file[DP_CTRL][2];
assign default_action   = register_file[DP_CTRL][4:3];
assign irq_enble        = register_file[DP_CTRL][8:5];
assign stats_clear      = register_file[DP_CTRL][9];

// Write logic
always_ff @(posedge clk) begin
    if (rst) begin
        register_file[DP_CTRL] <= '0;
        wdone <= 1'b0;
    end
    else begin
        // Self-clear flow_table_flush & stats_clear
        register_file[DP_CTRL][2] <= 1'b0;
        register_file[DP_CTRL][9] <= 1'b0;

        wdone <= 1'b0;
        // READ-ONLY status from parser
        if (eth_ready) begin
            register_file[DST_MAC_L]   <= dst_mac[31:0];
            register_file[DST_MAC_H]   <= {16'b0, dst_mac[47:32]};
            register_file[SRC_MAC_L]   <= src_mac[31:0];
            register_file[SRC_MAC_H]   <= {16'b0, src_mac[47:32]};
            register_file[ETH_TYPE]    <= {16'b0, eth_type};
        end

        if (ipv4_ready) begin
            register_file[SRC_IP]      <= src_ip;
            register_file[DST_IP]      <= dst_ip;
            register_file[PROTOCOL]    <= {16'b0, protocol};
        end

        if (udp_tcp_ready) begin
            register_file[UDP_PORT]    <= {udp_src_port[15:0], udp_dst_port[15:0]};
            register_file[TCP_PORT]    <= {tcp_src_port[15:0], tcp_dst_port[15:0]};
        end

        if (flow_key_valid) begin
            register_file[FLOW_KEY_32]  <= flow_key[31:0];
            register_file[FLOW_KEY_64]  <= flow_key[63:32];
            register_file[FLOW_KEY_96]  <= flow_key[95:64];
            register_file[FLOW_KEY_128] <= flow_key[127:96];
        end

        // Write control register
        if (we) begin
            case (waddr[5:2])
                4'h1:   register_file[DP_CTRL] <= wdata;
                // Add more RW control registers here
                default: ; // ignore writes to RO registers
            endcase
            wdone <= 1'b1;
        end
    end
end

// Read logic
always_ff @(posedge clk) begin
    if (rst) begin
        rdata <= 32'b0;
        rdone <= 1'b0;
    end
    else begin
        rdone <= 1'b0;
        if (re) begin
            rdone <= 1'b1;
            case (raddr[5:2])
                4'h1,
                DST_MAC_L,
                DST_MAC_H,
                SRC_MAC_L,
                SRC_MAC_H,
                ETH_TYPE,
                SRC_IP,
                DST_IP,
                PROTOCOL,
                UDP_PORT,
                TCP_PORT,
                FLOW_KEY_32,
                FLOW_KEY_64,
                FLOW_KEY_96,
                FLOW_KEY_128:
                    rdata <= register_file[raddr[5:2]];
                default:
                    rdata <= 32'hDEADBEEF;
            endcase
        end
    end
end

endmodule