interface axi_if(input logic clk, input logic rst_n);

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
    @(posedge clk);
    AWADDR  = addr;
    AWVALID = 1;
    WDATA   = data;
    WSTRB   = 4'b1111;
    WVALID  = 1;

    // AW and W channels are independent — handle them in parallel
    fork
        begin : aw_channel
            fork
                begin
                    @(posedge clk iff (AWVALID && AWREADY));
                    AWVALID = 0;
                end
                begin
                    #500ns;
                    $error("Timeout waiting for AWREADY");
                end
            join_any
            disable fork;
        end
        begin : w_channel
            fork
                begin
                    @(posedge clk iff (WVALID && WREADY));
                    WVALID = 0;
                end
                begin
                    #500ns;
                    $error("Timeout waiting for WREADY");
                end
            join_any
            disable fork;
        end
    join

    // Write response — assert BREADY before waiting for BVALID
    BREADY = 1;
    fork
        begin
            @(posedge clk iff (BVALID && BREADY));
            BREADY = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for BVALID");
        end
    join_any
    disable fork;
endtask

// AXI4-Lite Read Task
task automatic read(input logic [31:0] addr, output logic [31:0] data);
    @(posedge clk);
    ARADDR  = addr;
    ARVALID = 1;
    RREADY  = 1;

    fork
        begin
            @(posedge clk iff (ARVALID && ARREADY));
            ARVALID = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for ARREADY");
        end
    join_any
    disable fork;

    fork
        begin
            @(posedge clk iff (RVALID && RREADY));
            data   = RDATA;
            RREADY = 0;
        end
        begin
            #500ns;
            $error("Timeout waiting for RVALID");
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