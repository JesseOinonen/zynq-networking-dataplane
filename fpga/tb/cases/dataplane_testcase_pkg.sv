
package dataplane_testcase_pkg;
    `include "../top/register.svh"

    task dataplane_testcase(input axi_lite_if axi, input logic clk, input logic rst_n);
        @(posedge rst_n);
        $display("Running dataplane_testcase...");
        axi.write(ADDR, DATA);
        repeat (500) @(posedge clk);
        $display("Completed dataplane_testcase.");
    endtask

endpackage