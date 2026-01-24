interface axi_if(input logic clk);

// AXI4-Lite signals
logic [31:0] AWADDR, WDATA, ARADDR, RDATA;
logic        AWVALID, WVALID, ARVALID, RREADY, BREADY;
logic        AWREADY, WREADY, ARREADY, RVALID, BVALID;
logic [3:0]  WSTRB;
logic [1:0]  BRESP, RRESP;
logic [2:0]  AWPROT, ARPROT;

// AXI Stream signals
logic        tvalid;
logic [63:0] tdata;
logic [7:0]  tkeep;
logic        tlast;
logic        tready;

// AXI4-Lite Write Task
task automatic write(input logic [31:0] addr, input logic [31:0] data);
    AWADDR  = addr;
    WDATA   = data;
    AWVALID = 1; 
    WVALID = 1; 
    WSTRB = 4'b1111;
    fork
        begin
            wait (AWREADY && WREADY);
            @(posedge clk) 
            AWVALID = 0; 
            WVALID = 0;
            BREADY = 1; 
        end
        begin
            #500ns;
            $error("Timeout waiting for AWREADY or WREADY response");
        end
    join_any
    disable fork;

    fork
        begin
            wait(BVALID); 
            @(posedge clk) 
            BREADY = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for BVALID response");
        end
    join_any
    disable fork;
endtask

// AXI4-Lite Read Task
task automatic read(input logic [31:0] addr, output logic [31:0] data);
    ARADDR = addr; 
    ARVALID = 1; 
    fork
        begin
            wait(ARREADY); 
            @(posedge clk) 
            ARVALID = 0;
            RREADY = 1; 
        end
        begin
            #500ns;
            $error("Timeout waiting for ARREADY response");
        end
    join_any
    disable fork;

    fork
        begin
            wait(RVALID); 
            @(posedge clk) 
            data = RDATA; 
            RREADY = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for RVALID response");
        end
    join_any
    disable fork;
endtask

// AXI Stream send beat
task automatic stream_send(input logic [63:0] data, input logic [7:0] keep, input logic last);
    tdata  = data;
    tkeep  = keep;
    tlast  = last;
    tvalid = 1;
    fork
        begin
            wait (tready);
            @(posedge clk) 
            tvalid = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for tready response");
        end
    join_any
    disable fork;
endtask

endinterface