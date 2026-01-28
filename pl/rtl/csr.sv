import dataplane_pkg::*;

module csr (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] waddr,     // Write address
    input  logic [31:0] wdata,     // Write data
    input  logic        we,        // Write enable
    input  logic [31:0] raddr,     // Read address
    input  logic        re,        // Read enable
    input  logic [47:0] dst_mac,   // Destination MAC from parser
    input  logic [47:0] src_mac,   // Source MAC from parser
    input  logic [15:0] eth_type,  // Ethertype from parser
    input  logic        eth_ready, // Indicates new Ethernet frame parsed
    output logic [31:0] rdata,     // Read data
    output logic        rdone,     // Read done
    output logic        wdone      // Write done
);

logic [31:0] register_file [0:15];

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

        // Read/Write control register write
        if (we) begin
            case (waddr[5:2])
                `CSR_CTRL:   register_file[`CSR_CTRL] <= wdata;
                default: ; // ignore writes to RO registers
            endcase
            wdone <= 1'b1;
        end
    end
end


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
                `SRC_PORT_DST:
                    rdata <= register_file[raddr[5:2]];
                default:
                    rdata <= 32'hDEADBEEF;
            endcase
        end
    end
end

endmodule