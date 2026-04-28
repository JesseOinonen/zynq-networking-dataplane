package dp_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "register.svh"

    // Sequence items
    `include "axi_lite_seq_item.sv"
    `include "axi_stream_seq_item.sv"

    // AXI Lite agent
    `include "axi_lite_driver.sv"
    `include "axi_lite_monitor.sv"
    `include "axi_lite_scoreboard.sv"
    `include "axi_lite_agent.sv"

    // AXI Stream agent
    `include "axi_stream_driver.sv"
    `include "axi_stream_monitor.sv"
    `include "axi_stream_agent.sv"

    // Sequences
    `include "axi_lite_seq.sv"
    `include "parser_seq.sv"

    // Virtual sequence base
    `include "dp_vseq_base.sv"

    // Environment and test base
    `include "dp_env.sv"
    `include "dp_test_base.sv"

    // Tests
    `include "axi4_lite_test.sv"
    `include "parser_test.sv"
    `include "flow_key_gen_test.sv"
    `include "flow_table_test.sv"
    `include "action_stage_test.sv"
endpackage
