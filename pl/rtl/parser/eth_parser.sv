module eth_parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    data_valid_in,
    input  logic                    last_flag_in,
    output logic [DATA_WIDTH-1:0]   tdata_out,
    output logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_out,
    output logic                    data_valid_out,
    output logic                    last_flag_out,
    output logic                    eth_parser_ready,
    output logic [47:0]             dst_mac,
    output logic [47:0]             src_mac,
    output logic [15:0]             eth_type,
    output logic [ 3:0]             wcnt_eth
);

logic [3:0] counter;
logic [3:0] wcnt;
logic       sop;
logic       in_packet;

// Packet state tracking
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_packet <= 1'b0;
    end
    else if (data_valid_in) begin
        if (last_flag_in)
            in_packet <= 1'b0;   // end of packet
        else
            in_packet <= 1'b1;   // inside packet
    end
end

// SOP = first valid beat when not already in packet
assign sop = data_valid_in && !in_packet;


// Pass through the data to ipv4 parser
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tdata_out      <= '0;
        idx_out        <= '0;
        data_valid_out <= 1'b0;
        last_flag_out  <= 1'b0;
    end 
    else begin
        tdata_out      <= tdata_in;
        idx_out        <= idx_in;
        data_valid_out <= data_valid_in;
        last_flag_out  <= last_flag_in;
    end
end

// Ethernet header parsing
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter          <= '0;
        eth_parser_ready <= 1'b0;
        dst_mac          <= '0;
        src_mac          <= '0;
        eth_type         <= '0;
        wcnt_eth         <= '0;
    end 
    else begin
        wcnt_eth <= '0;
        if (data_valid_in && !eth_parser_ready) begin
            wcnt = 0;
            for (int i = 0; i < idx_in; i++) begin
                if ((counter + wcnt) < 6)       dst_mac[(5 - (counter + wcnt))*8 +: 8]   <= tdata_in[i*8 +: 8];
                else if ((counter + wcnt) < 12) src_mac[(11 - (counter + wcnt))*8 +: 8]  <= tdata_in[i*8 +: 8];
                else if ((counter + wcnt) < 14) eth_type[(13 - (counter + wcnt))*8 +: 8] <= tdata_in[i*8 +: 8];
                wcnt++;
                // When 14 bytes have been received ethernet header is complete
                if ((counter + wcnt) >= 14) begin
                    eth_parser_ready <= 1'b1;
                    wcnt_eth <= wcnt;
                    counter <= '0;
                    wcnt = 0;
                    break;
                end
            end
            counter <= counter + wcnt;
        end
        if (sop) begin
            eth_parser_ready <= 1'b0;
        end
    end
end

endmodule