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