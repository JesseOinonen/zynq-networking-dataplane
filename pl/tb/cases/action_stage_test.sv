class action_stage_vseq extends dp_vseq_base;

    `uvm_object_utils(action_stage_vseq)

    function new(string name = "action_stage_vseq");
        super.new(name);
    endfunction

    task body();
        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10ns;
        axi4_write(`CSR_ACTION_CTRL, 32'h2);

        #10us;

        `uvm_info("ACTION_STAGE_TEST", "action_stage_testcase completed", UVM_LOW)
    endtask

endclass

class action_stage_test extends dp_test_base;
    `uvm_component_utils(action_stage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        action_stage_vseq vseq = action_stage_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask

endclass
