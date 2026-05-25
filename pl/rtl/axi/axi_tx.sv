module axi_tx #(
    parameter DATA_WIDTH  = 64,
    parameter DEPTH       = 256,
    parameter ALMOST_FULL = DEPTH - 8
)(
    input  logic                    clk,
    input  logic                    rst,
    // Input from axis_mux
    input  logic                    tvalid_mux,
    input  logic [DATA_WIDTH-1:0]   tdata_mux,
    input  logic [DATA_WIDTH/8-1:0] tkeep_mux,
    input  logic                    tlast_mux,
    output logic                    tready_mux,
    // Output to MAC/PHY
    input  logic                    tready_out,
    output logic                    tvalid_out,
    output logic [DATA_WIDTH-1:0]   tdata_out,
    output logic [DATA_WIDTH/8-1:0] tkeep_out,
    output logic                    tlast_out
);

// Backpressure handling/buffering


endmodule