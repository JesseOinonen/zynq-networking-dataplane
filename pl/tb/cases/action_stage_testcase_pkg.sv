package action_stage_testcase_pkg;
    `include "../top/register.svh"

    task action_stage_testcase(input virtual axi_if axi, output int passed, output int total);

        $display("Running action_stage_testcase...");

        #10ns;

        total++;
        // Write to action table
        axi.write(32'h4003FFFC, 32'h2);
        passed++;

        $display("Completed action_stage_testcase.");
    endtask

endpackage