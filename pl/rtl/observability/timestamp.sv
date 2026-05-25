module timestamp #(
    parameter DATA_WIDTH  = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    output logic [63:0]             ts
);

// Timestamp generation
always_ff @(posedge clk) begin
    if (rst) begin
        ts <= '0;
    end
    else begin
        ts <= ts + 1;
    end
end

endmodule
