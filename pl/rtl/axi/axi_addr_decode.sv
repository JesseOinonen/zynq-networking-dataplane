module axi_addr_decode (
    input  logic [31:0] waddr,
    input  logic [31:0] wdata,
    input  logic        we,
    input  logic        wdone_flow,
    input  logic        wdone_csr,
    input  logic        rdone_csr,
    input  logic [31:0] rdata_csr,
    input  logic [31:0] raddr,
    input  logic        re,
    output logic        re_csr,
    output logic        we_csr,
    output logic [31:0] waddr_csr,
    output logic [31:0] wdata_csr,
    output logic [31:0] raddr_csr,
    output logic        we_flow,
    output logic [7:0]  waddr_flow,
    output logic [31:0] wdata_flow,
    output logic        wdone,
    output logic        rdone,
    output logic [31:0] rdata
);


// Write enables
assign we_csr  = we && (waddr[31] == 1'b0);
assign we_flow = we && (waddr[31] == 1'b1);

// Write addresses / data
assign waddr_csr  = we_csr  ? waddr       : '0;
assign wdata_csr  = we_csr  ? wdata       : '0;
assign waddr_flow = we_flow ? waddr[9:2]  : '0; // hash the address from flow_key in PS
assign wdata_flow = we_flow ? wdata       : '0;

// Done signals
assign wdone = we_csr ? wdone_csr : we_flow ? wdone_flow : 1'b0;

// Read address (only CSR)
assign raddr_csr = raddr;
assign re_csr    = re;
assign rdata     = rdata_csr;
assign rdone     = rdone_csr;

endmodule