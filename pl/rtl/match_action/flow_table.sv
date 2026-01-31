import dataplane_pkg::*;

module flow_table (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [127:0] flow_key,
    input  logic         flow_key_valid,
    input  logic [7:0]   waddr,      // Write address
    input  logic [31:0]  wdata,      // Write data
    input  logic         we,         // Write enable
    output logic         flow_hit,
    output logic [15:0]  flow_id,
    output logic         wdone       // Write done
);

logic [15:0] hash;
logic [2:0] wr_cnt;

typedef struct packed {
    logic         valid;
    logic [127:0] key;
    logic [15:0]  id;
} flow_entry_t;

flow_entry_t wr_entry_tmp;

// Force BRAM
(* ram_style = "block" *) flow_entry_t flow_table [0:255];

flow_entry_t rd_entry;
logic [7:0]   addr;
logic [127:0] flow_key_d;

assign hash = flow_key[15:0] ^ flow_key[31:16] ^ flow_key[47:32] ^ flow_key[63:48];

always_ff @(posedge clk) begin
    if (!rst_n) begin
        flow_hit <= 0;
        flow_id  <= '0;
    end
    else begin
        if (flow_key_valid) begin
            addr       <= hash[7:0];
            flow_key_d <= flow_key;
        end

        rd_entry <= flow_table[addr];

        flow_hit <= rd_entry.valid && (rd_entry.key == flow_key_d);
        flow_id  <= rd_entry.id;
    end
end

// Write flow_table from PS (AXI4-lite, 32bits at a time)
// Need to capture latest wr_cnt to register and use its value
always_ff @(posedge clk) begin
    wdone <= 1'b0;
    if (we) begin
        case(wr_cnt)
            3'd0: wr_entry_tmp.key[31:0]   <= wdata;
            3'd1: wr_entry_tmp.key[63:32]  <= wdata;
            3'd2: wr_entry_tmp.key[95:64]  <= wdata;
            3'd3: wr_entry_tmp.key[127:96] <= wdata;
            3'd4: {wr_entry_tmp.valid, wr_entry_tmp.id} <= wdata[16:0]; 
        endcase

        wr_cnt <= wr_cnt + 1;

        if (wr_cnt == 3'd4) begin
            flow_table[waddr] <= wr_entry_tmp;
            wr_cnt <= 0;
        end
        wdone <= 1'b1;
    end
end

endmodule