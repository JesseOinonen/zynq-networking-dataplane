module upd_tcp_parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_in,
    input  logic                    last_flag_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    data_valid_in,
    input  logic                    ipv4_parser_ready,
    input  logic [7:0]              protocol,
    output logic                    upd_tcp_parser_ready,
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
    output logic [15:0]             tcp_urgent_pointer
);

logic [2:0]  udp_counter;
logic [4:0]  tcp_counter;

// UPD/TCP header parsing
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        udp_counter          <= '0;
        tcp_counter          <= '0;
        upd_tcp_parser_ready <= 1'b0;
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
            if (data_valid_in && ipv4_parser_ready && !upd_tcp_parser_ready) begin
                for (int i = 0; i < idx_in; i++) begin
                    case (tcp_counter)
                        0,1: tcp_src_port[(1 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        2,3: tcp_dst_port[(3 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        4,5,6,7: tcp_seq_num[(7 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        8,9,10,11: tcp_ack_num[(11 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        12: begin
                                tcp_data_offset <= tdata_in[i*8 +: 4];
                                tcp_flags[5:4] <= tdata_in[i*8 + 4 +: 2];
                            end
                        13: tcp_flags[3:0] <= tdata_in[i*8 +: 4];
                        14,15: tcp_window_size[(15 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        16,17: tcp_checksum[(17 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        18,19: tcp_urgent_pointer[(19 - tcp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        default: ;
                    endcase
                    tcp_counter++;
                    if (tcp_counter >= 20) begin
                        tcp_counter <= '0;
                        upd_tcp_parser_ready <= 1'b1;
                        break;
                    end
                end
            end
        end
        else if (protocol == 17) begin // UDP
            if (data_valid_in && ipv4_parser_ready && !upd_tcp_parser_ready) begin
                for (int i = 0; i < idx_in; i++) begin
                    case (udp_counter)
                        0,1: udp_src_port[(1 - udp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        2,3: udp_dst_port[(3 - udp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        4,5: udp_length[(5 - udp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        6,7: udp_checksum[(7 - udp_counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                        default: ;
                    endcase
                    udp_counter++;
                    if (udp_counter >= 8) begin
                        udp_counter <= '0;
                        upd_tcp_parser_ready <= 1'b1;
                        break;
                    end
                end
            end
        end
        if (last_flag_in) begin
            upd_tcp_parser_ready <= 1'b0;
        end
    end
end

endmodule