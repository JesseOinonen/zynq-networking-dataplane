module axi_rx #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    tvalid,
    input  logic [DATA_WIDTH-1:0]   tdata,
    input  logic [DATA_WIDTH/8-1:0] tkeep,
    input  logic                    tlast,
    output logic                    tready,
    output logic [$clog2(DATA_WIDTH/8+1)-1:0] idx, // Index of valid bytes
    output logic [DATA_WIDTH-1:0]   tdata_out,     // AXI-Stream valid data
    output logic                    data_valid,    // Indicates valid data received
    output logic                    last_flag      // Indicates last beat of a packet
);

assign tready = 1'b1;
assign last_flag = tlast;
logic [$clog2(DATA_WIDTH/8+1)-1:0] widx;

// Data reception logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tdata_out <= '0;
        idx <= '0;
        data_valid <= 1'b0;
    end 
    else begin
        data_valid <= 1'b0;
        if (tvalid && tready) begin
            widx = 0;
            for (int beat = 0; beat < DATA_WIDTH/8; beat++) begin
                if (tkeep[beat]) begin
                    tdata_out[widx*8 +: 8] <= tdata[beat*8 +: 8];
                    widx++;
                end
            end
            data_valid <= 1'b1;
            idx <= widx;
        end
    end
end

endmodule