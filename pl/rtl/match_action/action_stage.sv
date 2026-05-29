import dataplane_pkg::*;

module action_stage #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    flow_hit, // flow_table hit
    input  logic [9:0]              flow_id,  // flow_table input
    input  logic [9:0]              waddr,    // AXI4-Lite write address
    input  logic [31:0]             wdata,    // AXI4-Lite write data
    input  logic                    we,       // AXI4-Lite write enable
    input  logic                    sop_in,   // Start of packet signal for modify action
    output logic                    wdone,    // AXI4-Lite write done
    output logic                    trap,
    output logic                    drop_pulse, // 1-cycle pulse on SOP of a dropped packet
    // AXI stream signals
    input  logic [DATA_WIDTH-1:0]   tdata_in,
    input  logic                    tvalid_in,
    input  logic                    tlast_in,
    input  logic [DATA_WIDTH/8-1:0] tkeep_in,
    input  logic                    tready_in,
    output logic [DATA_WIDTH-1:0]   tdata_out  = '0,
    output logic                    tvalid_out = 1'b0,
    output logic                    tlast_out  = 1'b0,
    output logic [DATA_WIDTH/8-1:0] tkeep_out  = '0,
    // AXI stream signals for trap output to PS
    output logic [DATA_WIDTH-1:0]   tdata_s2mm  = '0,
    output logic                    tvalid_s2mm = 1'b0,
    output logic                    tlast_s2mm  = 1'b0,
    output logic [DATA_WIDTH/8-1:0] tkeep_s2mm  = '0,
    input  logic                    tready_s2mm
);

logic [2:0] axi_w_counter;
logic [9:0] waddr_ff; // Registered address for modify action check

logic       modify_done     = 1'b0;
logic [1:0] modify_counter  = '0;

typedef struct packed {
    logic        drop;
    logic        forward;
    logic        modify;
    logic        trap;
    logic        valid;
    logic [9:0]  flow_id;
    // L2
    logic [47:0] dst_mac;
    logic [47:0] src_mac;
    // L3
    logic [31:0] dst_ip;
    logic [31:0] src_ip;
    // L4
    logic [15:0] dst_port;
    logic [15:0] src_port;
} action_t;

// action_table BRAM / 1024 entrys
(* ram_style = "block" *) action_t action_table [0:1023];

// AXI4-Lite write to Action Table
always_ff @(posedge clk) begin
    if (rst) begin
        wdone         <= 1'b0;
        axi_w_counter <= '0;
        waddr_ff      <= '0;
    end
    else begin
        wdone <= 1'b0;
        if (we && !wdone) begin
            if (axi_w_counter < 1) begin
                action_table[waddr].drop    <= wdata[0];
                action_table[waddr].forward <= wdata[1];
                action_table[waddr].modify  <= wdata[2];
                action_table[waddr].trap    <= wdata[3];
                action_table[waddr].valid   <= !wdata[2]; // If not modify, then action is valid, else we need more writes to get modified macs
                action_table[waddr].flow_id  <= waddr;
                axi_w_counter                <= wdata[2];  // Set counter to 1 if modify action is expected, else 0 to accept new entries
                waddr_ff                     <= waddr;     // capture address for modify action check
            end
            else if (waddr == waddr_ff) begin // axi_w_counter should be set to 1 if modify action is expected, make sure we are writing to the same address for subsequent mac writes
                axi_w_counter <= axi_w_counter + 1;
                if (axi_w_counter < 7) begin
                        case (axi_w_counter)
                            1: action_table[waddr].dst_mac[31:0] <= wdata[31:0];
                            2: action_table[waddr].src_mac[31:0] <= wdata[31:0];
                            3: begin
                                action_table[waddr].dst_mac[47:32] <= wdata[15:0];
                                action_table[waddr].src_mac[47:32] <= wdata[31:16];
                            end
                            4: action_table[waddr].dst_ip <= wdata;
                            5: action_table[waddr].src_ip <= wdata;
                            6: begin
                                action_table[waddr].dst_port <= wdata[15:0];
                                action_table[waddr].src_port <= wdata[31:16];
                                action_table[waddr].valid    <= 1'b1;
                                axi_w_counter                <= '0;
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
always_ff @(posedge clk) begin
    if (tready_in) begin
        trap       <= 1'b0;
        drop_pulse <= 1'b0;
        if (flow_hit) begin
            if (action_table[flow_id].valid && action_table[flow_id].flow_id == flow_id) begin
                if (action_table[flow_id].drop) begin
                    tvalid_out <= 1'b0;
                    if (sop_in) drop_pulse <= 1'b1; // pulse once per dropped packet
                end
                else if (action_table[flow_id].forward) begin
                    tdata_out  <= tdata_in;
                    tvalid_out <= tvalid_in;
                    tlast_out  <= tlast_in;
                    tkeep_out  <= tkeep_in;
                end
                else if (action_table[flow_id].modify) begin
                    if (!modify_done) begin
                        if (modify_counter == 0) begin
                            tdata_out[31:0]  <= action_table[flow_id].dst_mac[31:0];
                            tdata_out[47:32] <= action_table[flow_id].dst_mac[47:32];
                            tdata_out[63:48] <= action_table[flow_id].src_mac[15:0];
                            tvalid_out       <= 1'b1;
                            tkeep_out        <= '1;
                            tlast_out        <= tlast_in;
                            modify_counter <= modify_counter + 1;
                        end
                        else if (modify_counter == 1) begin
                            tdata_out[31:0]  <= action_table[flow_id].src_mac[47:16];
                            tdata_out[63:32] <= action_table[flow_id].dst_ip;
                            tvalid_out       <= 1'b1;
                            tkeep_out        <= '1;
                            tlast_out        <= tlast_in;
                            modify_counter   <= modify_counter + 1;
                        end
                        else if (modify_counter == 2) begin
                            tdata_out[31:0]   <= action_table[flow_id].src_ip;
                            tdata_out[63:32]  <= {action_table[flow_id].dst_port, action_table[flow_id].src_port};
                            tvalid_out        <= 1'b1;
                            tkeep_out         <= '1;
                            tlast_out         <= tlast_in;
                            modify_done       <= 1'b1;
                            modify_counter    <= '0;
                        end
                    end
                    else begin
                        tdata_out        <= tdata_in;
                        tvalid_out       <= tvalid_in;
                        tkeep_out        <= tkeep_in;
                        tlast_out        <= tlast_in;
                        if (tlast_in) modify_done <= 1'b0; // Reset for next packet
                    end
                end
                if (action_table[flow_id].trap) begin
                    if (tready_s2mm) begin
                        trap        <= 1'b1;
                        tdata_s2mm  <= tdata_in;
                        tvalid_s2mm <= tvalid_in;
                        tkeep_s2mm  <= tkeep_in;
                        tlast_s2mm  <= tlast_in;
                    end
                end
                else begin
                    trap        <= 1'b0;
                    tdata_s2mm  <= '0;
                    tvalid_s2mm <= 1'b0;
                    tkeep_s2mm  <= '0;
                    tlast_s2mm  <= 1'b0;
                end
            end
        end
        else begin
            tdata_out        <= tdata_in;
            tvalid_out       <= tvalid_in;
            tkeep_out        <= tkeep_in;
            tlast_out        <= tlast_in;
        end
    end
end

endmodule
