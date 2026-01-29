import dataplane_pkg::*;

module csr (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] waddr,      // Write address
    input  logic [31:0] wdata,      // Write data
    input  logic        we,         // Write enable
    input  logic [31:0] raddr,      // Read address
    input  logic        re,         // Read enable
    input  logic [47:0] dst_mac,    // Destination MAC from parser
    input  logic [47:0] src_mac,    // Source MAC from parser
    input  logic [15:0] eth_type,   // Ethertype from parser
    input  logic        eth_ready,  // Indicates new Ethernet frame parsed
    input  logic        ipv4_ready, // Indicates new IPv4 header parsed
    input  logic [31:0] src_ip,     // Source IP from parser
    input  logic [31:0] dst_ip,     // Destination IP from parser
    input  logic [7:0]  protocol,   // Protocol from parser
    input  logic        udp_tcp_ready,
    input  logic [15:0] udp_src_port,
    input  logic [15:0] udp_dst_port,
    input  logic [15:0] tcp_src_port,
    input  logic [15:0] tcp_dst_port,
    output logic [31:0] rdata,      // Read data
    output logic        rdone,      // Read done
    output logic        wdone       // Write done
);

logic [31:0] register_file [0:15];


// Write logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 16; i++) begin
            register_file[i] <= 32'b0;
        end
        wdone <= 1'b0;
    end
    else begin
        wdone <= 1'b0;
        // READ-ONLY status from parser
        if (eth_ready) begin
            register_file[`DST_MAC_L] <= dst_mac[31:0];
            register_file[`DST_MAC_H] <= {16'b0, dst_mac[47:32]};
            register_file[`SRC_MAC_L] <= src_mac[31:0];
            register_file[`SRC_MAC_H] <= {16'b0, src_mac[47:32]};
            register_file[`ETH_TYPE]  <= {16'b0, eth_type};
        end
        if (ipv4_ready) begin
            register_file[`SRC_IP]    <= src_ip;
            register_file[`DST_IP]    <= dst_ip;
            register_file[`PROTOCOL]  <= {16'b0, protocol};
        end
        if (udp_tcp_ready) begin
            register_file[`UDP_PORT]  <= {udp_src_port[15:0], udp_dst_port[15:0]};
            register_file[`TCP_PORT]  <= {tcp_src_port[15:0], tcp_dst_port[15:0]};
        end

        // Write control register
        if (we) begin
            case (waddr[5:2])
                `CSR_CTRL:   register_file[`CSR_CTRL] <= wdata;
                // Add more RW control registers here
                default: ; // ignore writes to RO registers
            endcase
            wdone <= 1'b1;
        end
    end
end

// Read logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 32'b0;
        rdone <= 1'b0;
    end
    else begin
        rdone <= 1'b0;
        if (re) begin
            rdone <= 1'b1;
            case (raddr[5:2])
                `CSR_CTRL,
                `DST_MAC_L,
                `DST_MAC_H,
                `SRC_MAC_L,
                `SRC_MAC_H,
                `ETH_TYPE,
                `SRC_IP,
                `DST_IP,
                `PROTOCOL,
                `UDP_PORT,
                `TCP_PORT:
                    rdata <= register_file[raddr[5:2]];
                default:
                    rdata <= 32'hDEADBEEF;
            endcase
        end
    end
end

endmodule