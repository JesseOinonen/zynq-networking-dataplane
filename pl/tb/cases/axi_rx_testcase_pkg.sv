package axi_rx_testcase_pkg;
    `include "../top/register.svh"

    task axi_rx_testcase(input virtual axi_if axi);

        $display("Running axi_rx_testcase...");
        axi.stream_send(64'hABCDEF10ABCDEF10, 8'hFF, 1'h0);
        axi.stream_send(64'h4353456346346343, 8'hFF, 1'h0);
        axi.stream_send(64'h4378654876545566, 8'hFF, 1'h0);
        axi.stream_send(64'h123456789ABCDEF0, 8'hFF, 1'h1);
        #10ns;
        
        $display("Completed axi_rx_testcase.");
    endtask

endpackage