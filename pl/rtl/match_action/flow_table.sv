module flow_table (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [127:0] flow_key,
    input  logic         flow_key_valid,
    output logic         flow_hit,
    output logic [15:0]  flow_id
);

endmodule