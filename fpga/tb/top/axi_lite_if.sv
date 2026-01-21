interface axi_lite_if(input logic clk);

logic [31:0] AWADDR, WDATA, ARADDR, RDATA;
logic        AWVALID, WVALID, ARVALID, RREADY, BREADY;
logic        AWREADY, WREADY, ARREADY, RVALID, BVALID;
logic [3:0]  WSTRB;
logic [1:0]  BRESP, RRESP;
logic [2:0]  AWPROT, ARPROT;

task automatic write(input logic [31:0] addr, input logic [31:0] data);
    AWADDR  = addr;
    WDATA   = data;
    AWVALID = 1; 
    WVALID = 1; 
    WSTRB = 4'b1111;
    wait (AWREADY && WREADY);
    @(posedge clk) 
    AWVALID = 0; 
    WVALID = 0;
    BREADY = 1; 
    wait(BVALID); 
    @(posedge clk) 
    BREADY = 0;
endtask

task automatic read(input logic [31:0] addr, output logic [31:0] data);
    ARADDR = addr; 
    ARVALID = 1; 
    wait(ARREADY); 
    @(posedge clk) 
    ARVALID = 0;
    RREADY = 1; 
    wait(RVALID); 
    @(posedge clk) 
    data = RDATA; 
    RREADY = 0;
endtask

endinterface