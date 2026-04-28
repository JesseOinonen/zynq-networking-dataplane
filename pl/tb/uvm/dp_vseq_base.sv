class dp_vseq_base extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(dp_vseq_base)

    uvm_sequencer #(axi_lite_seq_item)   axi_lite_seqr;
    uvm_sequencer #(axi_stream_seq_item) axi_stream_seqr;

    function new(string name = "dp_vseq_base");
        super.new(name);
    endfunction

    task body();
    endtask

endclass
