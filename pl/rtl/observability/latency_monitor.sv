module latency_monitor (
    input  logic        clk,
    input  logic        rst,
    input  logic        sop_rx,       // 1-cycle pulse: packet enters RX FIFO
    input  logic        sop_tx,       // 1-cycle pulse: packet starts on TX output
    input  logic        stats_clear,
    output logic [31:0] latency_last, // pipeline latency of last packet (clock cycles)
    output logic [31:0] latency_min,
    output logic [31:0] latency_max
);

logic [31:0] timer;
logic        measuring;

always_ff @(posedge clk) begin
    if (rst || stats_clear) begin
        timer        <= '0;
        measuring    <= 1'b0;
        latency_last <= '0;
        latency_min  <= '1;  // all-ones so first real measurement always wins
        latency_max  <= '0;
    end 
    else begin
        // Start timer on RX SOP (only if not already measuring a previous packet)
        if (sop_rx && !measuring) begin
            timer     <= '0;
            measuring <= 1'b1;
        end 
        else if (measuring) begin
            timer <= timer + 1;
        end

        // Latch result on TX SOP
        if (sop_tx && measuring) begin
            latency_last <= timer;
            if (timer < latency_min) latency_min <= timer;
            if (timer > latency_max) latency_max <= timer;
            measuring    <= 1'b0;
        end
    end
end

endmodule
