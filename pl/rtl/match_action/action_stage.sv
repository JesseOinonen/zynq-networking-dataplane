import dataplane_pkg::*;

module action_stage (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flow_hit, // flow_table hit
    input  logic [15:0] flow_id,  // flow_table input
    input  logic [15:0] waddr,    // AXI4-Lite write address
    input  logic [31:0] wdata,    // AXI4-Lite write data
    input  logic        we,       // AXI4-Lite write enable
    output logic        wdone     // AXI4-Lite write done
    // ADD AXI STREAM SIGNALS TO AXI_TX
);

// UNFINISHED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


logic [9:0] action_idx;

typedef struct packed {
    logic        drop;
    logic        forward;
    logic        modify;
    logic [3:0]  out_port;
    logic        trap;
    logic        count;
    logic        valid;
    logic [15:0] flow_id;
} action_t;

// action_table BRAM / 1024 entrys
action_t action_table [0:1023];

assign action_idx = flow_hit ? flow_id[9:0] : '0;

// AXI4-Lite write
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wdone <= 1'b0;
    end
    else begin
        wdone <= 1'b0;
        if (we) begin
            action_table[action_idx].drop     <= wdata[0];
            action_table[action_idx].forward  <= wdata[1];
            action_table[action_idx].modify   <= wdata[2];
            action_table[action_idx].out_port <= wdata[6:3];
            action_table[action_idx].trap     <= wdata[7];
            action_table[action_idx].count    <= wdata[8];
            action_table[action_idx].valid    <= 1'b1;
            action_table[action_idx].flow_id  <= waddr[15:0];
            wdone <= 1'b1;
        end
    end
end


always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trap       <= 1'b0;
        tdata_out  <= '0;
        tvalid_out <= 1'b0;
        tlast_out  <= 1'b0;
    end
    else begin
        trap <= 1'b0;
        if (flow_hit) begin
           if (action_table[action_idx].valid && action_table[action_idx].flow_id == flow_id) begin
                if (action_table[action_idx].drop) begin
                    tlast_out <= 1'b0;
                end
                else if (action_table[action_idx].forward) begin
                    tdata_out <= packet_data;
                end
                else if (action_table[action_idx].modify) begin
                    tdata_out <= modify_packet(packet_data);
                end
                if (action_table[action_idx].trap) begin
                    trap <= 1'b1;
                end
           end
        end
    end
end

endmodule
