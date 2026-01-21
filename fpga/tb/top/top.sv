import dataplane_testcase_pkg::*;

module top; 
    logic clk;
    logic rst_n;

    rst_gen u_rst_gen (
        .rst_n(rst_n)
    );

    clk_gen50MHz u_clk_gen50MHz (
        .clk(clk)
    );

    axi_lite_if tb_axi(clk);

    axi_lite_slave u_axi_lite_slave (
        .clk    (clk),
        .rst_n  (rst_n),
        .AWADDR (tb_axi.AWADDR),
        .AWPROT (tb_axi.AWPROT),
        .AWVALID(tb_axi.AWVALID),
        .AWREADY(tb_axi.AWREADY),
        .WDATA  (tb_axi.WDATA),
        .WSTRB  (tb_axi.WSTRB),
        .WVALID (tb_axi.WVALID),
        .WREADY (tb_axi.WREADY),
        .BREADY (tb_axi.BREADY),
        .BVALID (tb_axi.BVALID),
        .BRESP  (tb_axi.BRESP),
        .ARADDR (tb_axi.ARADDR),
        .ARPROT (tb_axi.ARPROT),
        .ARVALID(tb_axi.ARVALID),
        .ARREADY(tb_axi.ARREADY),
        .RREADY (tb_axi.RREADY),
        .RVALID (tb_axi.RVALID),
        .RDATA  (tb_axi.RDATA),
        .RRESP  (tb_axi.RRESP)
    );

    initial begin
        tb_axi.AWADDR  = '0; 
        tb_axi.WDATA   = '0;
        tb_axi.ARADDR  = '0;
        tb_axi.RDATA   = '0;
        tb_axi.AWVALID = 0;
        tb_axi.WVALID  = 0;
        tb_axi.ARVALID = 0; 
        tb_axi.RREADY  = 0;
        tb_axi.BREADY  = 0;
        tb_axi.AWREADY = 0; 
        tb_axi.WREADY  = 0; 
        tb_axi.ARREADY = 0;
        tb_axi.RVALID  = 0;
        tb_axi.BVALID  = 0;
        tb_axi.WSTRB   = '0;
        tb_axi.BRESP   = '0;
        tb_axi.RRESP   = '0;
        tb_axi.AWPROT  = '0;
        tb_axi.ARPROT  = '0;

        wait (rst_n == 1);
        
        dataplane_axi4_lite_testcase(tb_axi, clk, rst_n);
        $finish;
    end
    
    
endmodule