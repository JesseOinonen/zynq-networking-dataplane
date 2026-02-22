// Testcases
import axi4_lite_testcase_pkg::*;
import axi_rx_testcase_pkg::*;
import flow_key_gen_testcase_pkg::*;
import flow_table_testcase_pkg::*;
import action_stage_testcase_pkg::*;

`timescale 1ns/1ps

module top; 
    logic clk;
    logic rst_n;
    int   passed;
    int   total;

    rst_gen u_rst_gen (
        .rst_n(rst_n)
    );

    clk_gen50MHz u_clk_gen50MHz (
        .clk(clk)
    );

    axi_if tb_axi(clk);

    dataplane_top #(.DATA_WIDTH(64)) u_dataplane_top (
        .clk125 (clk),
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
        .RRESP  (tb_axi.RRESP),
        .tvalid (tb_axi.tvalid),
        .tdata  (tb_axi.tdata),
        .tkeep  (tb_axi.tkeep),
        .tlast  (tb_axi.tlast),
        .tready (tb_axi.tready)
    );

    task automatic run_test(string name, output int passed, output int total);
        passed = 0;
        total  = 0;

        if      (name == "axi4_lite")    axi4_lite_testcase(tb_axi, passed, total);
        else if (name == "axi_rx")       axi_rx_testcase(tb_axi, passed, total);
        else if (name == "flow_key_gen") flow_key_gen_testcase(tb_axi, passed, total);
        else if (name == "flow_table")   flow_table_testcase(tb_axi, passed, total);
        else if (name == "action_stage") action_stage_testcase(tb_axi, passed, total);
        else    $fatal(1, "Unknown test '%s'", name);

    endtask

    initial begin
        string testname;

        tb_axi.AWADDR  = '0; 
        tb_axi.WDATA   = '0;
        tb_axi.ARADDR  = '0;
        tb_axi.AWVALID = 0;
        tb_axi.WVALID  = 0;
        tb_axi.ARVALID = 0; 
        tb_axi.RREADY  = 0;
        tb_axi.BREADY  = 0;
        tb_axi.ARREADY = 0;
        tb_axi.WSTRB   = '0;
        tb_axi.AWPROT  = '0;
        tb_axi.ARPROT  = '0;
        tb_axi.tvalid  = 0;
        tb_axi.tdata   = '0;
        tb_axi.tkeep   = '0;
        tb_axi.tlast   = 0;

        // Get test name from plusargs, default to axi4_lite
        if (!$value$plusargs("TEST=%s", testname)) begin
            testname = "flow_table";
        end

        $display("Starting testbench...");
        wait (rst_n == 1);
        $display("Rst detected...");

        $display("Starting testbench... TEST=%s", testname);

        run_test(testname, passed, total);

        $display("RESULT: %0d / %0d PASSED (TEST=%s)", passed, total, testname);

        #1us;

        if (passed != total) $fatal(1, "TEST FAILED");
        else $finish;
    end
    
endmodule