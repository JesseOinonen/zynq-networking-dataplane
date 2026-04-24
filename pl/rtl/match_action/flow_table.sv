import dataplane_pkg::*;

module flow_table (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [127:0]            flow_key,
    input  logic                    flow_key_valid,
    input  logic [9:0]              waddr,           // AXI4-Lite write address
    input  logic [31:0]             wdata,           // AXI4-Lite write data
    input  logic                    we,              // AXI4-Lite write enable
    output logic                    flow_hit,        // Flow table hit
    output logic [9:0]              flow_id,         // Flow id from flow table
    output logic                    wdone,           // AXI4-Lite write done 
    // AXI stream signals for action stage
    input  logic                    tvalid_in,
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic [DATA_WIDTH/8-1:0] tkeep_in,
    input  logic                    tlast_in,
    output logic                    tvalid_out,
    output logic [DATA_WIDTH-1:0]   tdata_out,
    output logic [DATA_WIDTH/8-1:0] tkeep_out,
    output logic                    tlast_out
);

logic [15:0] hash;
logic [9:0]  hash_idx;
logic [2:0]  wr_cnt;
logic        flow_table_rdy;

typedef struct packed {
    logic         valid;
    logic [127:0] key;
    logic [9:0]   id;
} flow_entry_t;

flow_entry_t wr_entry_tmp;

// BRAM Flow Table
(* ram_style = "block" *) flow_entry_t flow_table [0:1023];

flow_entry_t  rd_entry;
logic [9:0]   addr;
logic [127:0] flow_key_d;

assign hash     = flow_key[15:0]   ^ flow_key[31:16]  ^ flow_key[47:32]  ^ flow_key[63:48]
                ^ flow_key[79:64]  ^ flow_key[95:80]  ^ flow_key[111:96] ^ flow_key[127:112];
assign hash_idx = hash[9:0] ^ {4'b0, hash[15:10]};

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tvalid_out <= 1'b0;
        tdata_out  <= '0;
        tkeep_out  <= '0;
        tlast_out  <= 1'b0;
    end
    else begin
        tvalid_out <= tvalid_in;
        tdata_out  <= tdata_in;
        tkeep_out  <= tkeep_in;
        tlast_out  <= tlast_in;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flow_hit   <= 0;
        flow_id    <= '0;
        addr       <= '0;
        flow_key_d <= '0;
        rd_entry   <= '0;
    end
    else begin
        if (flow_key_valid) begin
            addr       <= hash_idx;
            flow_key_d <= flow_key;
        end

        rd_entry <= flow_table[addr];
        flow_hit <= rd_entry.valid && (rd_entry.key == flow_key_d);
        flow_id  <= rd_entry.id;
    end
end

// Write flow_table from PS (AXI4-lite, 32bits at a time)
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_cnt         <= '0;
        wdone          <= 1'b0;
        wr_entry_tmp   <= '0;
        flow_table_rdy <= 1'b0;
        for (int i = 0; i < 1024; i++) begin
            flow_table[i] <= '0;
        end
    end
    else begin
        if (flow_table_rdy) begin 
            flow_table[waddr] <= wr_entry_tmp;
            flow_table_rdy    <= 1'b0;
            wr_entry_tmp      <= '0;
        end
        wdone          <= 1'b0;
        if (we && !wdone) begin
            case(wr_cnt)
                3'd0: wr_entry_tmp.key[31:0]   <= wdata;
                3'd1: wr_entry_tmp.key[63:32]  <= wdata;
                3'd2: wr_entry_tmp.key[95:64]  <= wdata;
                3'd3: wr_entry_tmp.key[127:96] <= wdata;
                3'd4: {wr_entry_tmp.valid, wr_entry_tmp.id} <= wdata[10:0]; 
            endcase

            wr_cnt <= wr_cnt + 1;

            if (wr_cnt == 3'd4) begin
                wr_cnt            <= 0;
                flow_table_rdy    <= 1'b1;
            end
            wdone <= 1'b1;
        end
    end
end

endmodule