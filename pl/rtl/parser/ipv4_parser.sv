module ipv4_parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    data_valid_in,
    input  logic                    eth_parser_ready,
    input  logic                    last_flag_in,
    output logic [DATA_WIDTH-1:0]   tdata_out,
    output logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_out,
    output logic                    data_valid_out,
    output logic                    last_flag_out,
    output logic                    ipv4_parser_ready,
    output logic [31:0]             src_ip,
    output logic [31:0]             dst_ip,
    output logic [7:0]              protocol
);

logic [4:0]  counter;
logic [3:0]  ihl;
logic [3:0]  version;
logic [5:0] ipv4_header_length;


assign ipv4_header_length = (ihl >= 5) ? (ihl << 2) : 6'd20;

// Pass through the data to UPD/TCP parser
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

// IPV4 header parsing
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter           <= '0;
        ipv4_parser_ready <= 1'b0;
        ihl               <= '0;
        version           <= '0;
        protocol          <= '0;
        src_ip            <= '0;
        dst_ip            <= '0;
    end 
    else begin
        if (data_valid_in && eth_parser_ready && !ipv4_parser_ready) begin
            for (int i = 0; i < idx_in; i++) begin
                case (counter)
                    0: begin
                            ihl <= tdata_in[i*8 +: 4];
                            version <= tdata_in[i*8 + 4 +: 4];
                        end
                    9: protocol <= tdata_in[i*8 +: 8];
                    12,13,14,15: src_ip[(15-counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                    16,17,18,19: dst_ip[(19-counter)*8 +: 8] <= tdata_in[i*8 +: 8];
                endcase
                counter++;
                // When ipv4_header_length bytes have been received IPV4 header is complete
                if (counter >= ipv4_header_length ) begin
                    ipv4_parser_ready <= 1'b1;
                    counter <= '0;
                    break;
                end
            end
        end
        if (!eth_parser_ready) begin
            ipv4_parser_ready <= 1'b0;
        end
    end
end

endmodule