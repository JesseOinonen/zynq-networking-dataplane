class axi4_lite_vseq extends dp_vseq_base;

    `uvm_object_utils(axi4_lite_vseq)

    function new(string name = "axi4_lite_vseq");
        super.new(name);
    endfunction

    task body();
        axi_lite_write_seq wr_seq;
        axi_lite_read_seq  rd_seq;

        wr_seq      = axi_lite_write_seq::type_id::create("wr_seq");
        wr_seq.addr = `CSR_CTRL;
        wr_seq.data = 32'hAAAAAAAA;
        wr_seq.start(axi_lite_seqr);

        rd_seq      = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = `CSR_CTRL;
        rd_seq.start(axi_lite_seqr);

        if (rd_seq.data !== 32'hAAAAAAAA)
            `uvm_error("AXI4_LITE_TEST", $sformatf("Data mismatch: expected 0xAAAAAAAA, got 0x%08X", rd_seq.data))
        else
            `uvm_info("AXI4_LITE_TEST", $sformatf("Data match successful: 0x%08X", rd_seq.data), UVM_LOW)
    endtask

endclass

class axi4_lite_test extends dp_test_base;
    `uvm_component_utils(axi4_lite_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        axi4_lite_vseq vseq = axi4_lite_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr = env.axi_agent.seqr;
        vseq.start(null);
    endtask

endclass
