module axi_rx #(
    parameter DATA_WIDTH  = 64,
    parameter DEPTH       = 256,
    parameter ALMOST_FULL = DEPTH - 8
)(
    input  logic                    clk,
    input  logic                    rst,
    // Input from MAC/PHY
    input  logic                    tvalid,
    input  logic [DATA_WIDTH-1:0]   tdata,
    input  logic [DATA_WIDTH/8-1:0] tkeep,
    input  logic                    tlast,
    output logic                    tready,
    // Output to dataplane
    input  logic                    out_tready,
    output logic                    out_tvalid,
    output logic [DATA_WIDTH-1:0]   out_tdata,
    output logic [DATA_WIDTH/8-1:0] out_tkeep,
    output logic                    out_tlast,
    output logic                    sop, // Start of Packet
    output logic                    in_packet, // Indicates if currently receiving a packet
    // Control
    input  logic                    enable
);

localparam ADDR_W  = $clog2(DEPTH);
localparam ENTRY_W = DATA_WIDTH + DATA_WIDTH/8 + 1; // tdata + tkeep + tlast

logic [ENTRY_W-1:0] mem [0:DEPTH-1];
logic [ADDR_W:0]    wr_ptr;
logic [ADDR_W:0]    rd_ptr;
logic [ADDR_W:0]    count;
logic               empty;

assign count  = wr_ptr - rd_ptr;
assign empty  = (count == '0);
assign tready = (count < ADDR_W+1'(ALMOST_FULL)) && enable;

// Packet state tracking
always_ff @(posedge clk) begin
    if (rst) begin
        in_packet <= 1'b0;
    end
    else if (tvalid && tready) begin
        if (tlast) begin
            in_packet <= 1'b0;
        end
        else begin
            in_packet <= 1'b1;
        end
    end
end

// SOP = first valid beat when not already in packet
assign sop = tvalid && !in_packet && enable;

// Write
always_ff @(posedge clk) begin
    if (rst) begin
        wr_ptr <= '0;
    end 
    else if (tvalid && tready) begin
        mem[wr_ptr[ADDR_W-1:0]] <= {tlast, tkeep, tdata};
        wr_ptr <= wr_ptr + 1;
    end
end

// Read
always_ff @(posedge clk) begin
    if (rst) begin
        rd_ptr     <= '0;
        out_tvalid <= 1'b0;
        out_tdata  <= '0;
        out_tkeep  <= '0;
        out_tlast  <= 1'b0;
    end 
    else begin
        if (!empty && out_tready) begin
            {out_tlast, out_tkeep, out_tdata} <= mem[rd_ptr[ADDR_W-1:0]];
            out_tvalid <= 1'b1;
            rd_ptr     <= rd_ptr + 1;
        end else if (out_tready) begin
            out_tvalid <= 1'b0;
        end
    end
end

endmodule
