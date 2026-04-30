module eth_parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic [DATA_WIDTH/8-1:0] tkeep_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    tvalid_in,
    input  logic                    tlast_in,
    input  logic                    sop,
    input  logic                    in_packet,
    output logic                    eth_parser_ready,
    output logic [47:0]             dst_mac,
    output logic [47:0]             src_mac,
    output logic [15:0]             eth_type,
    output logic [ 3:0]             wcnt_eth,
    // AXI stream outputs (pass through)
    output logic [DATA_WIDTH-1:0]   tdata_out  = '0,
    output logic [DATA_WIDTH/8-1:0] tkeep_out  = '0,
    output logic                    tvalid_out = 1'b0,
    output logic                    tlast_out  = 1'b0,
    output logic                    in_packet_out = 1'b0
);

logic [3:0] counter;
logic [3:0] wcnt;
logic       done;

// Pass through the data to ipv4 parser
always_ff @(posedge clk) begin
    tdata_out     <= tdata_in;
    tkeep_out     <= tkeep_in;
    tvalid_out    <= tvalid_in;
    tlast_out     <= tlast_in;
    in_packet_out <= in_packet;
end

// Ethernet header parsing
always_ff @(posedge clk) begin
    if (rst) begin
        counter          <= '0;
        eth_parser_ready <= 1'b0;
        dst_mac          <= '0;
        src_mac          <= '0;
        eth_type         <= '0;
        wcnt_eth         <= '0;
    end
    else begin
        wcnt_eth <= '0;
        if (tvalid_in && !eth_parser_ready) begin
            wcnt = 0;
            done = 1'b0;
            for (int i = 0; i < DATA_WIDTH/8; i++) begin
                if (!done && tkeep_in[i]) begin
                    if ((counter + wcnt) < 6)       dst_mac[(5 - (counter + wcnt))*8 +: 8]   <= tdata_in[i*8 +: 8];
                    else if ((counter + wcnt) < 12) src_mac[(11 - (counter + wcnt))*8 +: 8]  <= tdata_in[i*8 +: 8];
                    else if ((counter + wcnt) < 14) eth_type[(13 - (counter + wcnt))*8 +: 8] <= tdata_in[i*8 +: 8];
                    wcnt++;
                    if ((counter + wcnt) >= 14) begin
                        eth_parser_ready <= 1'b1;
                        wcnt_eth <= wcnt;
                        done = 1'b1;
                        wcnt = 0;
                    end
                end
            end
            if (done) counter <= '0;
            else      counter <= counter + wcnt;
        end
        if (sop) begin
            eth_parser_ready <= 1'b0;
        end
    end
end


endmodule
