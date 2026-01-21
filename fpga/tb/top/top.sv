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

    initial begin
        #1us;
        dataplane_testcase(tb_axi, clk, rst_n);
        #1us;
        $finish;
    end
    
    
endmodule