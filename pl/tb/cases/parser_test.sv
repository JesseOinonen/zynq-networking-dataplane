class parser_vseq extends dp_vseq_base;

    `uvm_object_utils(parser_vseq)

    function new(string name = "parser_vseq");
        super.new(name);
    endfunction

    task body();
        parser_seq   pkt_seq;
        logic [31:0] rdata;

        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10ns;

        pkt_seq = parser_seq::type_id::create("pkt_seq");
        pkt_seq.start(axi_stream_seqr);

        #10ns;

        axi4_read(`CSR_DST_MAC_L, rdata);
        if (rdata !== 32'h3040506) `uvm_error("PARSER_TEST", $sformatf("DST MAC LOW mismatch: expected 03040506, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "DST MAC LOW PASSED", UVM_LOW)

        axi4_read(`CSR_DST_MAC_H, rdata);
        if (rdata !== 32'hDA02) `uvm_error("PARSER_TEST", $sformatf("DST MAC HIGH mismatch: expected DA02, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "DST MAC HIGH PASSED", UVM_LOW)

        axi4_read(`CSR_SRC_MAC_L, rdata);
        if (rdata !== 32'h3040506) `uvm_error("PARSER_TEST", $sformatf("SRC MAC LOW mismatch: expected 03040506, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "SRC MAC LOW PASSED", UVM_LOW)

        axi4_read(`CSR_SRC_MAC_H, rdata);
        if (rdata !== 32'h5A02) `uvm_error("PARSER_TEST", $sformatf("SRC MAC HIGH mismatch: expected 5A02, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "SRC MAC HIGH PASSED", UVM_LOW)

        axi4_read(`CSR_ETH_TYPE, rdata);
        if (rdata !== 32'h0800) `uvm_error("PARSER_TEST", $sformatf("ETH TYPE mismatch: expected 0800, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "ETH TYPE PASSED", UVM_LOW)

        axi4_read(`CSR_SRC_IP, rdata);
        if (rdata !== 32'hC0A80101) `uvm_error("PARSER_TEST", $sformatf("SRC IP mismatch: expected C0A80101, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "SRC IP PASSED", UVM_LOW)

        axi4_read(`CSR_DST_IP, rdata);
        if (rdata !== 32'hC0A80102) `uvm_error("PARSER_TEST", $sformatf("DST IP mismatch: expected C0A80102, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "DST IP PASSED", UVM_LOW)

        axi4_read(`CSR_PROTOCOL, rdata);
        if (rdata !== 32'h000006) `uvm_error("PARSER_TEST", $sformatf("PROTOCOL mismatch: expected 06, got 0x%08X", rdata))
        else `uvm_info("PARSER_TEST", "PROTOCOL PASSED", UVM_LOW)

        axi4_read(`CSR_TCP_PORT, rdata);
        if (rdata[31:16] !== 16'h04D2) `uvm_error("PARSER_TEST", $sformatf("TCP SOURCE PORT mismatch: expected 04D2, got 0x%04X", rdata[31:16]))
        else `uvm_info("PARSER_TEST", "TCP SRC PORT PASSED", UVM_LOW)
        if (rdata[15:0] !== 16'h0050) `uvm_error("PARSER_TEST", $sformatf("TCP DESTINATION PORT mismatch: expected 0050, got 0x%04X", rdata[15:0]))
        else `uvm_info("PARSER_TEST", "TCP DST PORT PASSED", UVM_LOW)

        #10ns;
    endtask

endclass

class parser_test extends dp_test_base;
    `uvm_component_utils(parser_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        parser_vseq vseq = parser_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask

endclass
