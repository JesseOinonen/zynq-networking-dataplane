
package dataplane_testcase_pkg;
    `include "../top/register.svh"

    task dataplane_axi4_lite_testcase(input virtual axi_lite_if axi, input logic clk, input logic rst_n);
        logic [31:0] read_data;
        
        @(posedge rst_n);
        $display("Running dataplane_axi4_lite_testcase...");
        @(posedge clk);
        axi.write(32'hffffffff, 32'hAAAAAAAA);
        repeat (10) @(posedge clk);
        axi.read(32'hffffffff, read_data);
        if (read_data !== 32'hAAAAAAAA) begin
            $error("Data mismatch: expected 0xAAAAAAAA, got 0x%08X", read_data);
        end 
        else begin
            $display("Data match successful: 0x%08X", read_data);
        end
        $display("Completed dataplane_axi4_lite_testcase.");
    endtask

endpackage