package action_stage_testcase_pkg;
    `include "../top/register.svh"

    task action_stage_testcase(input virtual axi_if axi, output int passed, output int total);

        $display("Running action_stage_testcase...");

        #10ns;

        total++;
        // Write to action table
        // Try to write all of the possible actions
        // Do one where all actions are set at the same time
        // make also writes to incorrect addresses when modify action is expected
        axi.write(32'h4003FFFC, 32'h2);
        passed++;

        #10us;
        
        $display("Completed action_stage_testcase.");
    endtask

endpackage