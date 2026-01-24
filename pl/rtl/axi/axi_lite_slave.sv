module axi_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    // Write address signals (AW channel)
    input  logic [31:0] AWADDR,  
    input  logic [ 2:0] AWPROT,  
    input  logic        AWVALID, 
    output logic        AWREADY, 
    // Write data (W channel)
    input  logic [31:0] WDATA,   
    input  logic [ 3:0] WSTRB,   
    input  logic        WVALID,  
    output logic        WREADY,  
    // Write response (B channel)
    input  logic        BREADY,  
    output logic        BVALID,  
    output logic [ 1:0] BRESP,   
    // Read address (AR channel)
    input  logic [31:0] ARADDR,  
    input  logic [ 2:0] ARPROT,  
    input  logic        ARVALID, 
    output logic        ARREADY, 
    // Read data (R channel)
    input  logic        RREADY,  
    output logic        RVALID,  
    output logic [31:0] RDATA,   
    output logic [ 1:0] RRESP,
    // Signals to register interface
    input  logic        wdone,  // Write done
    input  logic [31:0] rdata,  // Read data
    input  logic        rdone,  // Read done
    output logic [31:0] waddr,  // Write address
    output logic [31:0] wdata,  // Write data
    output logic        we,     // Write enable
    output logic [31:0] raddr,  // Read address
    output logic        re      // Read enable
);

logic awaddr_valid;
logic wdata_valid;

// WRITE
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AWREADY      <= 1'b1;
        WREADY       <= 1'b1;
        BVALID       <= 1'b0;
        BRESP        <= 2'b00;
        awaddr_valid <= 1'b0;
        wdata_valid  <= 1'b0;
        wdata        <= 32'b0;
        waddr        <= 32'b0;
        we           <= 1'b0;
    end 
    else begin

        // Write address (AW)
        if (AWVALID && AWREADY) begin
            waddr <= AWADDR;
            awaddr_valid <= 1'b1;
            AWREADY <= 1'b0;
        end

        // Write data (W)
        if (WVALID && WREADY) begin
            wdata <= WDATA;
            wdata_valid <= 1'b1;
            WREADY <= 1'b0;
        end

        // Write response (B)
        if (wdone && awaddr_valid && wdata_valid) begin
            BVALID <= 1'b1;
            BRESP  <= 2'b00; // OKAY response
            AWREADY <= 1'b1;
            WREADY  <= 1'b1;
            we <= 1'b0;
            awaddr_valid <= 1'b0;
            wdata_valid <= 1'b0;
        end
        if (BVALID && BREADY) begin
            BVALID <= 1'b0;
        end

        // Write is ready when both address and data are captured
        if (awaddr_valid && wdata_valid) begin
            we <= 1'b1;
        end
    end
end


// READ
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ARREADY <= 1'b1;
        RVALID  <= 1'b0;
        BVALID  <= 1'b0;
        RRESP   <= 2'b00;
        RDATA   <= 32'b0;
        re      <= 1'b0;
        raddr   <= 32'b0;
    end 
    else begin
        // Read address (AR)
        if (ARVALID && ARREADY) begin
            raddr   <= ARADDR;
            ARREADY <= 1'b0;
            re      <= 1'b1;
        end

        // Read data (R)
        if (rdone) begin
            RDATA  <= rdata;
            RRESP  <= 2'b00; // OKAY response
            RVALID <= 1'b1;
            re     <= 1'b0;
        end
        if (RVALID && RREADY) begin
            RVALID  <= 1'b0;
            ARREADY <= 1'b1;
        end
    end
end


endmodule