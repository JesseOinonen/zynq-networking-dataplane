module axi_rx #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    tvalid,
    input  logic [DATA_WIDTH-1:0]   tdata,
    input  logic [DATA_WIDTH/8-1:0] tkeep,
    input  logic                    tlast,
    input  logic                    parser_ready,  // Parser is ready to accept data
    output logic                    tready,
    output logic [$clog2(DATA_WIDTH/8+1)-1:0] idx, // Index of valid bytes
    output logic [DATA_WIDTH-1:0]   data_buffer,   // AXI-Stream valid data
    output logic                    last_flag      // Indicates last beat of a packet
);

assign tready = parser_ready;
assign last_flag = tlast;

// Data reception logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_buffer <= '0;
        idx <= 0;
    end 
    else begin
        // AXI-Stream handshake
        if (tvalid && tready) begin
            idx <= 0;
            for (int beat = 0; beat < DATA_WIDTH/8; beat++) begin
                if (tkeep[beat]) begin
                    data_buffer[idx*8 +: 8] <= tdata[idx*8 +: 8];
                    idx++;
                end
            end
        end
    end
end

endmodule