
package dataplane_testcase_pkg;
    `include "../top/register.svh"

    task dataplane_axi4_lite_testcase(input virtual axi_lite_if axi);
        logic [31:0] read_data;

        $display("Running dataplane_axi4_lite_testcase...");
        
        axi.write(32'h4, 32'hAAAAAAAA);

        #10ns;
        
        axi.read(32'h4, read_data);
        if (read_data !== 32'hAAAAAAAA) begin
            $error("Data mismatch: expected 0xAAAAAAAA, got 0x%08X", read_data);
        end 
        else begin
            $display("Data match successful: 0x%08X", read_data);
        end
        $display("Completed dataplane_axi4_lite_testcase.");
    endtask

endpackage