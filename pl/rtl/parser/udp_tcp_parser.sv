module udp_tcp_parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    // AXI stream inputs
    input  logic [DATA_WIDTH/8-1:0] tkeep_in,
    input  logic                    tlast_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    tvalid_in,
    // Control signals from previous parsers
    input  logic                    ipv4_parser_ready,
    input  logic [7:0]              protocol,
    input  logic [4:0]              wcnt_ipv4,
    input  logic                    in_packet,
    input  logic                    sop_in,
    // UDP/TCP header outputs
    output logic                    udp_tcp_parser_ready,
    output logic [15:0]             udp_src_port,
    output logic [15:0]             udp_dst_port,
    output logic [15:0]             udp_length,
    output logic [15:0]             udp_checksum,
    output logic [15:0]             tcp_src_port,
    output logic [15:0]             tcp_dst_port,
    output logic [31:0]             tcp_seq_num,
    output logic [31:0]             tcp_ack_num,
    output logic [3:0]              tcp_data_offset,
    output logic [5:0]              tcp_flags,
    output logic [15:0]             tcp_window_size,
    output logic [15:0]             tcp_checksum,
    output logic [15:0]             tcp_urgent_pointer,
    output logic                    sop_out      = 1'b0,
    // AXI stream outputs (pass through)
    output logic                    tvalid_out = 1'b0,
    output logic [DATA_WIDTH-1:0]   tdata_out  = '0,
    output logic [DATA_WIDTH/8-1:0] tkeep_out  = '0,
    output logic                    tlast_out  = 1'b0
);

logic [2:0] udp_counter;
logic [4:0] tcp_counter;
logic [4:0] wcnt;
logic       done;

// Pass through AXI stream signals
always_ff @(posedge clk) begin
    tvalid_out <= tvalid_in;
    tdata_out  <= tdata_in;
    tkeep_out  <= tkeep_in;
    tlast_out  <= tlast_in;
    sop_out    <= sop_in;
end

// UDP/TCP header parsing
always_ff @(posedge clk) begin
    if (rst) begin
        udp_counter          <= '0;
        tcp_counter          <= '0;
        udp_tcp_parser_ready <= 1'b0;
        tcp_src_port         <= '0;
        tcp_dst_port         <= '0;
        tcp_seq_num          <= '0;
        tcp_ack_num          <= '0;
        tcp_data_offset      <= '0;
        tcp_flags            <= '0;
        tcp_window_size      <= '0;
        tcp_checksum         <= '0;
        tcp_urgent_pointer   <= '0;
        udp_src_port         <= '0;
        udp_dst_port         <= '0;
        udp_length           <= '0;
        udp_checksum         <= '0;
    end
    else begin
        if (protocol == 6) begin // TCP
            if (tvalid_in && ipv4_parser_ready && !udp_tcp_parser_ready) begin
                wcnt = 0;
                done = 1'b0;
                for (int i = 0; i < DATA_WIDTH/8; i++) begin
                    if (!done && tkeep_in[i] && i >= wcnt_ipv4) begin
                        case (tcp_counter+wcnt)
                            0,1:     tcp_src_port[(1 - (tcp_counter+wcnt))*8 +: 8]       <= tdata_in[i*8 +: 8];
                            2,3:     tcp_dst_port[(3 - (tcp_counter+wcnt))*8 +: 8]       <= tdata_in[i*8 +: 8];
                            4,5,6,7: tcp_seq_num[(7 - (tcp_counter+wcnt))*8 +: 8]        <= tdata_in[i*8 +: 8];
                            8,9,10,11: tcp_ack_num[(11 - (tcp_counter+wcnt))*8 +: 8]     <= tdata_in[i*8 +: 8];
                            12: begin
                                tcp_data_offset <= tdata_in[i*8 +: 4];
                                tcp_flags[5:4]  <= tdata_in[i*8 + 4 +: 2];
                            end
                            13:    tcp_flags[3:0]                                         <= tdata_in[i*8 +: 4];
                            14,15: tcp_window_size[(15 - (tcp_counter+wcnt))*8 +: 8]     <= tdata_in[i*8 +: 8];
                            16,17: tcp_checksum[(17 - (tcp_counter+wcnt))*8 +: 8]        <= tdata_in[i*8 +: 8];
                            18,19: tcp_urgent_pointer[(19 - (tcp_counter+wcnt))*8 +: 8]  <= tdata_in[i*8 +: 8];
                            default: ;
                        endcase
                        wcnt++;
                        if ((tcp_counter+wcnt) >= 20) begin
                            udp_tcp_parser_ready <= 1'b1;
                            done = 1'b1;
                            wcnt = 0;
                        end
                    end
                end
                if (done) tcp_counter <= '0;
                else      tcp_counter <= tcp_counter + wcnt;
            end
        end
        else if (protocol == 17) begin // UDP
            if (tvalid_in && ipv4_parser_ready && !udp_tcp_parser_ready) begin
                wcnt = 0;
                done = 1'b0;
                for (int i = 0; i < DATA_WIDTH/8; i++) begin
                    if (!done && tkeep_in[i] && i >= wcnt_ipv4) begin
                        case (udp_counter+wcnt)
                            0,1: udp_src_port[(1 - (udp_counter+wcnt))*8 +: 8] <= tdata_in[i*8 +: 8];
                            2,3: udp_dst_port[(3 - (udp_counter+wcnt))*8 +: 8] <= tdata_in[i*8 +: 8];
                            4,5: udp_length[(5 - (udp_counter+wcnt))*8 +: 8]   <= tdata_in[i*8 +: 8];
                            6,7: udp_checksum[(7 - (udp_counter+wcnt))*8 +: 8] <= tdata_in[i*8 +: 8];
                            default: ;
                        endcase
                        wcnt++;
                        if (((udp_counter+wcnt) >= 8) && !udp_tcp_parser_ready) begin
                            udp_tcp_parser_ready <= 1'b1;
                            done = 1'b1;
                            wcnt = 0;
                        end
                    end
                end
                if (done) udp_counter <= '0;
                else      udp_counter <= udp_counter + wcnt;
            end
        end
        if (tlast_in && in_packet) begin
            udp_tcp_parser_ready <= 1'b0;
        end
    end
end

endmodule
