module throughput_counter #(
    // Default window = 1 second at 125 MHz.
    // Set to a smaller value in simulation (e.g. 1250 for 10 µs windows).
    parameter int WINDOW_CYCLES = 125_000_000
)(
    input  logic       clk,
    input  logic       rst,
    // RX stream (axi_rx FIFO output)
    input  logic       rx_tvalid,
    input  logic       rx_tready,
    input  logic [7:0] rx_tkeep,
    input  logic       rx_tlast,
    // TX stream (axi_tx output to MAC)
    input  logic       tx_tvalid,
    input  logic       tx_tready,
    input  logic [7:0] tx_tkeep,
    input  logic       tx_tlast,
    input  logic       stats_clear,
    // Latched at end of each window
    output logic [31:0] rx_bytes,
    output logic [31:0] rx_packets,
    output logic [31:0] tx_bytes,
    output logic [31:0] tx_packets
);

function automatic logic [3:0] popcount8(input logic [7:0] k);
    logic [3:0] n;
    n = 4'(k[0]) + 4'(k[1]) + 4'(k[2]) + 4'(k[3]) +
        4'(k[4]) + 4'(k[5]) + 4'(k[6]) + 4'(k[7]);
    return n;
endfunction

logic [31:0] window_cnt;
logic        window_tick;

logic [31:0] rx_bytes_acc, rx_pkts_acc;
logic [31:0] tx_bytes_acc, tx_pkts_acc;

assign window_tick = (window_cnt == 32'(WINDOW_CYCLES) - 1);

always_ff @(posedge clk) begin
    if (rst || stats_clear) begin
        window_cnt   <= '0;
        rx_bytes_acc <= '0;
        rx_pkts_acc  <= '0;
        tx_bytes_acc <= '0;
        tx_pkts_acc  <= '0;
        rx_bytes     <= '0;
        rx_packets   <= '0;
        tx_bytes     <= '0;
        tx_packets   <= '0;
    end else begin
        window_cnt <= window_tick ? '0 : window_cnt + 1;

        if (window_tick) begin
            rx_bytes     <= rx_bytes_acc;
            rx_packets   <= rx_pkts_acc;
            tx_bytes     <= tx_bytes_acc;
            tx_packets   <= tx_pkts_acc;
            rx_bytes_acc <= '0;
            rx_pkts_acc  <= '0;
            tx_bytes_acc <= '0;
            tx_pkts_acc  <= '0;
        end

        if (rx_tvalid && rx_tready) begin
            rx_bytes_acc <= rx_bytes_acc + 32'(popcount8(rx_tkeep));
            if (rx_tlast) rx_pkts_acc <= rx_pkts_acc + 1;
        end

        if (tx_tvalid && tx_tready) begin
            tx_bytes_acc <= tx_bytes_acc + 32'(popcount8(tx_tkeep));
            if (tx_tlast) tx_pkts_acc <= tx_pkts_acc + 1;
        end
    end
end

endmodule
