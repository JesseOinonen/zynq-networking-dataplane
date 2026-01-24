module dataplane_top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] AWADDR,  
    input  logic [ 2:0] AWPROT,  
    input  logic        AWVALID, 
    output logic        AWREADY, 
    input  logic [31:0] WDATA,   
    input  logic [ 3:0] WSTRB,   
    input  logic        WVALID,  
    output logic        WREADY,  
    input  logic        BREADY,  
    output logic        BVALID,  
    output logic [ 1:0] BRESP,   
    input  logic [31:0] ARADDR,  
    input  logic [ 2:0] ARPROT,  
    input  logic        ARVALID, 
    output logic        ARREADY, 
    input  logic        RREADY,  
    output logic        RVALID,  
    output logic [31:0] RDATA,   
    output logic [ 1:0] RRESP
);

logic [31:0] waddr_sig;
logic [31:0] wdata_sig;
logic        we_sig;
logic [31:0] raddr_sig;
logic        re_sig;
logic [31:0] rdata_sig;
logic        rdone_sig;
logic        wdone_sig;

    axi_lite_slave u_axi_lite_slave (
        .clk(clk),
        .rst_n(rst_n),
        .AWADDR(AWADDR),  
        .AWPROT(AWPROT),  
        .AWVALID(AWVALID), 
        .AWREADY(AWREADY), 
        .WDATA(WDATA),   
        .WSTRB(WSTRB),   
        .WVALID(WVALID),  
        .WREADY(WREADY),  
        .BREADY(BREADY),  
        .BVALID(BVALID),  
        .BRESP(BRESP),   
        .ARADDR(ARADDR),  
        .ARPROT(ARPROT),  
        .ARVALID(ARVALID), 
        .ARREADY(ARREADY), 
        .RREADY(RREADY),  
        .RVALID(RVALID),  
        .RDATA(RDATA),   
        .RRESP(RRESP),
        .wdone(wdone_sig), 
        .rdata(rdata_sig), 
        .rdone(rdone_sig), 
        .waddr(waddr_sig), 
        .wdata(wdata_sig), 
        .we(we_sig),    
        .raddr(raddr_sig), 
        .re(re_sig)     
    );

    csr u_csr (
        .clk(clk),
        .rst_n(rst_n),
        .waddr(waddr_sig), 
        .wdata(wdata_sig), 
        .we(we_sig),    
        .raddr(raddr_sig), 
        .re(re_sig),    
        .rdata(rdata_sig), 
        .rdone(rdone_sig), 
        .wdone(wdone_sig)  
    );

endmodule