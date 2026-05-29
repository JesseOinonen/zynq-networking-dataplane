module error_counter (
    input  logic        clk,
    input  logic        rst,
    input  logic        rx_overflow,  // MAC tvalid asserted when axi_rx not ready
    input  logic        flow_miss,    // valid flow key looked up but no table hit
    input  logic        drop,         // drop action fired (1-cycle pulse per packet)
    input  logic        stats_clear,
    output logic [31:0] rx_overflow_count,
    output logic [31:0] flow_miss_count,
    output logic [31:0] drop_count
);

always_ff @(posedge clk) begin
    if (rst || stats_clear) begin
        rx_overflow_count <= '0;
        flow_miss_count   <= '0;
        drop_count        <= '0;
    end 
    else begin
        if (rx_overflow) rx_overflow_count <= rx_overflow_count + 1;
        if (flow_miss)   flow_miss_count   <= flow_miss_count   + 1;
        if (drop)        drop_count        <= drop_count        + 1;
    end
end

endmodule
