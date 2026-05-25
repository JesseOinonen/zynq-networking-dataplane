import uvm_pkg::*;
import dp_pkg::*;
`include "uvm_macros.svh"

`timescale 1ns/1ps

module top;
    logic clk;
    logic rst;

    rst_gen u_rst_gen (
        .rst(rst)
    );

    clk_gen125MHz u_clk_gen125MHz (
        .clk(clk)
    );

    axi_if tb_axi(clk, rst);

    dataplane_top #(.DATA_WIDTH(64)) u_dataplane_top (
        .clk         (clk),
        .rst         (rst),
        .AWADDR      (tb_axi.AWADDR),
        .AWPROT      (tb_axi.AWPROT),
        .AWVALID     (tb_axi.AWVALID),
        .AWREADY     (tb_axi.AWREADY),
        .WDATA       (tb_axi.WDATA),
        .WSTRB       (tb_axi.WSTRB),
        .WVALID      (tb_axi.WVALID),
        .WREADY      (tb_axi.WREADY),
        .BREADY      (tb_axi.BREADY),
        .BVALID      (tb_axi.BVALID),
        .BRESP       (tb_axi.BRESP),
        .ARADDR      (tb_axi.ARADDR),
        .ARPROT      (tb_axi.ARPROT),
        .ARVALID     (tb_axi.ARVALID),
        .ARREADY     (tb_axi.ARREADY),
        .RREADY      (tb_axi.RREADY),
        .RVALID      (tb_axi.RVALID),
        .RDATA       (tb_axi.RDATA),
        .RRESP       (tb_axi.RRESP),
        .tvalid_in   (tb_axi.tvalid_rx),
        .tdata_in    (tb_axi.tdata_rx),
        .tkeep_in    (tb_axi.tkeep_rx),
        .tlast_in    (tb_axi.tlast_rx),
        .tready_out  (tb_axi.tready_rx),
        .tvalid_out  (tb_axi.tvalid_tx),
        .tdata_out   (tb_axi.tdata_tx),
        .tkeep_out   (tb_axi.tkeep_tx),
        .tlast_out   (tb_axi.tlast_tx),
        .tready_in   (tb_axi.tready_tx),
        .tdata_mm2s  (tb_axi.tdata_mm2s),
        .tvalid_mm2s (tb_axi.tvalid_mm2s),
        .tkeep_mm2s  (tb_axi.tkeep_mm2s),
        .tlast_mm2s  (tb_axi.tlast_mm2s),
        .tready_mm2s (tb_axi.tready_mm2s),
        .tdata_s2mm  (tb_axi.tdata_s2mm),
        .tvalid_s2mm (tb_axi.tvalid_s2mm),
        .tkeep_s2mm  (tb_axi.tkeep_s2mm),   
        .tlast_s2mm  (tb_axi.tlast_s2mm),
        .tready_s2mm (tb_axi.tready_s2mm)
    );

    initial begin
        tb_axi.AWADDR     = '0;
        tb_axi.WDATA      = '0;
        tb_axi.ARADDR     = '0;
        tb_axi.AWVALID    = 0;
        tb_axi.WVALID     = 0;
        tb_axi.ARVALID    = 0;
        tb_axi.RREADY     = 0;
        tb_axi.BREADY     = 0;
        tb_axi.ARREADY    = 0;
        tb_axi.WSTRB      = '0;
        tb_axi.AWPROT     = '0;
        tb_axi.ARPROT     = '0;
        tb_axi.tvalid_rx  = 0;
        tb_axi.tdata_rx   = '0;
        tb_axi.tkeep_rx   = '0;
        tb_axi.tlast_rx   = 0;

        uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top", "axi_vif", tb_axi);

        // Run test, the test is selected with +UVM_TESTNAME=<name> plusarg
        run_test();
    end
    
endmodule