module dataplane_top #(
    parameter DATA_WIDTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,
    // AXI4-Lite interface
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
    output logic [ 1:0] RRESP,
    //AXI-Stream interface
    input  logic                    tvalid,
    input  logic [DATA_WIDTH-1:0]   tdata,
    input  logic [DATA_WIDTH/8-1:0] tkeep,
    input  logic                    tlast,
    output logic                    tready
);

logic [31:0] waddr_sig;
logic [31:0] wdata_sig;
logic        we_sig;
logic [31:0] raddr_sig;
logic        re_sig;
logic [31:0] rdata_sig;
logic        rdone_sig;
logic        wdone_sig;
logic        parser_ready_sig;
logic [$clog2(DATA_WIDTH/8+1)-1:0] idx_sig;
logic [DATA_WIDTH-1:0]   data_buffer_sig;
logic                    last_flag_sig;

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

axi_rx #(.DATA_WIDTH(DATA_WIDTH)) u_axi_rx (
    .clk(clk),
    .rst_n(rst_n),
    .tvalid(tvalid),
    .tdata(tdata),
    .tkeep(tkeep),
    .tlast(tlast),
    .parser_ready(parser_ready_sig),
    .tready(tready),
    .idx(idx_sig),
    .data_buffer(data_buffer_sig),
    .last_flag(last_flag_sig)
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

parser u_parser (
    .clk(clk),
    .rst_n(rst_n),
    .parser_ready(parser_ready_sig),
    .idx(idx_sig),
    .data_buffer(data_buffer_sig),
    .last_flag(last_flag_sig)
);

endmodule