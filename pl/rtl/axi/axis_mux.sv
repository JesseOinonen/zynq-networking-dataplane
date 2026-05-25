module axis_mux #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    // Dataplane (PL) — PL has priority
    input  logic                    tvalid_dp,
    input  logic [DATA_WIDTH-1:0]   tdata_dp,
    input  logic [DATA_WIDTH/8-1:0] tkeep_dp,
    input  logic                    tlast_dp,
    output logic                    tready_dp,
    // PS DMA MM2S
    input  logic                    tvalid_dma,
    input  logic [DATA_WIDTH-1:0]   tdata_dma,
    input  logic [DATA_WIDTH/8-1:0] tkeep_dma,
    input  logic                    tlast_dma,
    output logic                    tready_dma,
    // AXI TX output
    input  logic                    tready,
    output logic                    tvalid = 1'b0,
    output logic [DATA_WIDTH-1:0]   tdata  = '0,
    output logic [DATA_WIDTH/8-1:0] tkeep  = '0,
    output logic                    tlast  = 1'b0
);

logic sel;       // 0 = PL, 1 = DMA
logic in_packet; // locks sel for duration of current packet

// Only active source gets tready — drives the entire PL pipeline when sel=0
assign tready_dp  = tready && !sel;
assign tready_dma = tready &&  sel;

// Arbitration: PL priority, switch only between packets
always_ff @(posedge clk) begin
    if (rst) begin
        sel       <= 1'b0;
        in_packet <= 1'b0;
    end else begin
        if (!in_packet) begin
            if      (tvalid_dp)  sel <= 1'b0;
            else if (tvalid_dma) sel <= 1'b1;
        end

        if (tready) begin
            if (!sel && tvalid_dp)
                in_packet <= !tlast_dp;
            else if (sel && tvalid_dma)
                in_packet <= !tlast_dma;
        end
    end
end

// Output: registered, gated by tready
always_ff @(posedge clk) begin
    if (rst) begin
        tvalid <= 1'b0;
        tdata  <= '0;
        tkeep  <= '0;
        tlast  <= 1'b0;
    end else if (tready) begin
        if (!sel && tvalid_dp) begin
            tdata  <= tdata_dp;
            tkeep  <= tkeep_dp;
            tlast  <= tlast_dp;
            tvalid <= 1'b1;
        end else if (sel && tvalid_dma) begin
            tdata  <= tdata_dma;
            tkeep  <= tkeep_dma;
            tlast  <= tlast_dma;
            tvalid <= 1'b1;
        end else begin
            tvalid <= 1'b0;
        end
    end
end

endmodule
