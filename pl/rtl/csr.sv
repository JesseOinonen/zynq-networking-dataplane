module csr (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] waddr,  // Write address
    input  logic [31:0] wdata,  // Write data
    input  logic        we,     // Write enable
    input  logic [31:0] raddr,  // Read address
    input  logic        re,     // Read enable
    output logic [31:0] rdata,  // Read data
    output logic        rdone,  // Read done
    output logic        wdone   // Write done
);

logic [31:0] register_file [0:15];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 32'b0;
        rdone <= 1'b0;
        wdone <= 1'b0;
        // Initialize register file to zero
        for (int i = 0; i < 16; i++) begin
            register_file[i] <= '0;
        end
    end 
    else begin
        if (re) begin
            rdata <= register_file[raddr[5:2]]; // Assuming word-aligned addresses
            rdone <= 1'b1;
        end 
        else begin
            rdone <= 1'b0;
        end

        if (we) begin
            register_file[waddr[5:2]] <= wdata; // Assuming word-aligned addresses
            wdone <= 1'b1;
        end 
        else begin
            wdone <= 1'b0;
        end
    end
end

endmodule