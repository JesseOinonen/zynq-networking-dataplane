import dataplane_pkg::*;

module action_stage #(
    parameter DATA_WIDTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flow_hit, // flow_table hit
    input  logic [9:0]  flow_id,  // flow_table input
    input  logic [9:0]  waddr,    // AXI4-Lite write address
    input  logic [31:0] wdata,    // AXI4-Lite write data
    input  logic        we,       // AXI4-Lite write enable
    output logic        wdone     // AXI4-Lite write done
    //output logic        trap,
    //output logic [DATA_WIDTH-1:0] tdata_out,
    //output logic        tvalid_out,
    //output logic        tlast_out
);

// TEMP, should be outputs and get pipelined from parser stage !!!!!!!!!!!
logic trap;
logic [DATA_WIDTH-1:0] tdata_out;
logic tvalid_out;
logic tlast_out;

logic [2:0] axi_w_counter;
logic [9:0] waddr_ff; // Registered address for modify action check

typedef struct packed {
    logic        drop;
    logic        forward;
    logic        modify;
    logic [3:0]  out_port;
    logic        trap;
    logic        count;
    logic        valid;
    logic [9:0]  flow_id;
    logic [47:0] dst_mac;
    logic [47:0] src_mac;
} action_t;

// action_table BRAM / 1024 entrys
(* ram_style = "block" *) action_t action_table [0:1023];

// AXI4-Lite write to Action Table
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wdone         <= 1'b0;
        axi_w_counter <= '0;
        waddr_ff      <= '0;
    end
    else begin
        wdone <= 1'b0;
        if (we && !wdone) begin
            if (axi_w_counter < 1) begin
                action_table[waddr].drop     <= wdata[0];
                action_table[waddr].forward  <= wdata[1];
                action_table[waddr].modify   <= wdata[2];
                action_table[waddr].out_port <= wdata[6:3];
                action_table[waddr].trap     <= wdata[7];
                action_table[waddr].count    <= wdata[8];
                action_table[waddr].valid    <= !wdata[2]; // If not modify, then action is valid, else we need more writes to get modified macs
                action_table[waddr].flow_id  <= waddr;
                axi_w_counter                <= wdata[2];  // Set counter to 1 if modify action is expected, else 0 to accept new entries
                waddr_ff                     <= waddr;     // capture address for modify action check
            end
            else if (waddr == waddr_ff) begin // axi_w_counter should be set to 1 if modify action is expected, make sure we are writing to the same address for subsequent mac writes
                axi_w_counter <= axi_w_counter + 1;
                if (axi_w_counter < 4 && !action_table[waddr].valid) begin
                        case (axi_w_counter)
                            1: action_table[waddr].dst_mac[31:0] <= wdata[31:0];
                            2: action_table[waddr].src_mac[31:0] <= wdata[31:0];
                            3: begin
                                action_table[waddr].dst_mac[47:32] <= wdata[15:0];
                                action_table[waddr].src_mac[47:32] <= wdata[31:16];
                                action_table[waddr].valid          <= 1'b1;
                                axi_w_counter <= '0;
                            end
                            default: ;
                        endcase
                end
            end
            else begin // If waddr doesn't match with previous waddr and modify data is still expected
                axi_w_counter                <= '0;   // reset counter to avoid miswrites
                action_table[waddr_ff].valid <= 1'b0; // Make previous entry invalid as modify action data is not completely written
            end
            wdone <= 1'b1;
        end
    end
end

// Action Stage
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
           if (action_table[flow_id].valid && action_table[flow_id].flow_id == flow_id) begin
                if (action_table[flow_id].drop) begin
                    tlast_out <= 1'b0;
                end
                else if (action_table[flow_id].forward) begin
                //    tdata_out <= packet_data; // forward pipelined data coming from parser stage
                end
                else if (action_table[flow_id].modify) begin
                //    tdata_out <= modify_packet(packet_data); // modify pipelined data coming from parser based on action table
                end
                if (action_table[flow_id].trap) begin
                    trap <= 1'b1;
                end
           end
        end
    end
end

endmodule
