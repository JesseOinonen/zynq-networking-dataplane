module axi_tx #(
    parameter DATA_WIDTH = 64
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
    input  logic                    tready_in,
    output logic                    tvalid_out = 1'b0,
    output logic [DATA_WIDTH-1:0]   tdata_out  = '0,
    output logic [DATA_WIDTH/8-1:0] tkeep_out  = '0,
    output logic                    tlast_out  = 1'b0
);

// Propagate MAC backpressure upstream — freezes axis_mux and the full PL pipeline
assign tready_mux = tready_in;

always_ff @(posedge clk) begin
    if (rst) begin
        tvalid_out <= 1'b0;
        tdata_out  <= '0;
        tkeep_out  <= '0;
        tlast_out  <= 1'b0;
    end else if (tready_in) begin
        tvalid_out <= tvalid_mux;
        tdata_out  <= tdata_mux;
        tkeep_out  <= tkeep_mux;
        tlast_out  <= tlast_mux;
    end
end

endmodule
