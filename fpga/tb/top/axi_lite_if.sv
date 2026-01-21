interface axi_lite_if(input logic clk);
    logic [31:0] AWADDR, WDATA, ARADDR, RDATA;
    logic        AWVALID, WVALID, ARVALID, RREADY, BREADY;
    logic        AWREADY, WREADY, ARREADY, RVALID, BVALID;
    logic [3:0]  WSTRB;
    logic [1:0]  BRESP, RRESP;

    // Write task
    task automatic write(input logic [31:0] addr, input logic [31:0] data);
        AWADDR  = addr;
        WDATA   = data;
        AWVALID = 1; 
        WVALID = 1; 
        WSTRB = 4'b1111;
        wait (AWREADY && WREADY);
        AWVALID = 0; 
        WVALID = 0;
        BREADY = 1; 
        wait(BVALID); 
        BREADY = 0;
    endtask

    // Read task
    task automatic read(input logic [31:0] addr, output logic [31:0] data);
        ARADDR = addr; 
        ARVALID = 1; 
        wait(ARREADY); 
        ARVALID = 0;
        RREADY = 1; 
        wait(RVALID); 
        data = RDATA; 
        RREADY = 0;
    endtask
endinterface
