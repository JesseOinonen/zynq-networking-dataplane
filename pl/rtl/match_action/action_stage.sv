import dataplane_pkg::*;

module action_stage (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flow_hit, // flow_table hit
    input  logic [9:0]  flow_id,  // flow_table input
    // AXI4-Lite signals
    input  logic [9:0]  waddr,    // AXI4-Lite write address
    input  logic [31:0] wdata,    // AXI4-Lite write data
    input  logic        we,       // AXI4-Lite write enable
    output logic        wdone     // AXI4-Lite write done
    //AXI-Stream signals
);


logic [9:0] wr_idx;
logic [9:0] rd_idx;

typedef struct packed {
    logic        drop;
    logic        forward;
    logic        modify;
    logic [3:0]  out_port;
    logic        trap;
    logic        count;
    logic        valid;
    logic [9:0]  flow_id;
} action_t;

// action_table BRAM / 1024 entrys
(* ram_style = "block" *) action_t action_table [0:1023];

assign rd_idx = flow_hit ? flow_id : '0;
assign wr_idx = we ? waddr : '0;

// AXI4-Lite write to Action Table
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wdone <= 1'b0;
    end
    else begin
        wdone <= 1'b0;
        if (we) begin
            action_table[waddr].drop     <= wdata[0];
            action_table[waddr].forward  <= wdata[1];
            action_table[waddr].modify   <= wdata[2];
            action_table[waddr].out_port <= wdata[6:3];
            action_table[waddr].trap     <= wdata[7];
            action_table[waddr].count    <= wdata[8];
            action_table[waddr].valid    <= 1'b1;
            action_table[waddr].flow_id  <= waddr;
            wdone <= 1'b1;
        end
    end
end

// Action Stage
//always_ff @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        trap       <= 1'b0;
//        tdata_out  <= '0;
//        tvalid_out <= 1'b0;
//        tlast_out  <= 1'b0;
//    end
//    else begin
//        trap <= 1'b0;
//        if (flow_hit) begin
//           if (action_table[action_idx].valid && action_table[action_idx].flow_id == flow_id) begin
//                if (action_table[action_idx].drop) begin
//                    tlast_out <= 1'b0;
//                end
//                else if (action_table[action_idx].forward) begin
//                    tdata_out <= packet_data;
//                end
//                else if (action_table[action_idx].modify) begin
//                    tdata_out <= modify_packet(packet_data);
//                end
//                if (action_table[action_idx].trap) begin
//                    trap <= 1'b1;
//                end
//           end
//        end
//    end
//end

endmodule
