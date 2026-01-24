module parser #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [$clog2(DATA_WIDTH/8+1)-1:0] idx,
    input  logic [DATA_WIDTH-1:0]   data_buffer,
    input  logic                    last_flag,
    output logic                    parser_ready
    //output logic [31:0]             parsed_data,
    //output logic                    data_valid
);

// Placeholder
assign parser_ready = 1'b1;

endmodule