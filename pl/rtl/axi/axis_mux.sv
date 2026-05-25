module axis_mux #(
    parameter DATA_WIDTH  = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    // Input from dataplane
    input  logic                    tvalid_dp,
    input  logic [DATA_WIDTH-1:0]   tdata_dp,
    input  logic [DATA_WIDTH/8-1:0] tkeep_dp,
    input  logic                    tlast_dp,
    // Input from PS DMA
    input  logic                    tvalid_dma,
    input  logic [DATA_WIDTH-1:0]   tdata_dma,
    input  logic [DATA_WIDTH/8-1:0] tkeep_dma,
    input  logic                    tlast_dma,
    output logic                    tready_dma,
    // Output to AXI TX
    input  logic                    tready,
    output logic                    tvalid,
    output logic [DATA_WIDTH-1:0]   tdata,
    output logic [DATA_WIDTH/8-1:0] tkeep,
    output logic                    tlast
);

// Arbitration


endmodule
