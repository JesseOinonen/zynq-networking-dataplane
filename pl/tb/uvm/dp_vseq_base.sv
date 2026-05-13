class dp_vseq_base extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(dp_vseq_base)

    uvm_sequencer #(axi_lite_seq_item)   axi_lite_seqr;
    uvm_sequencer #(axi_stream_seq_item) axi_stream_seqr;

    function new(string name = "dp_vseq_base");
        super.new(name);
    endfunction

    task axi4_write(input logic [31:0] addr, input logic [31:0] data);
        axi_lite_write_seq wr_seq;
        wr_seq      = axi_lite_write_seq::type_id::create("wr_seq");
        wr_seq.addr = addr;
        wr_seq.data = data;
        wr_seq.start(axi_lite_seqr);
    endtask

    task axi4_read(input logic [31:0] addr, output logic [31:0] data);
        axi_lite_read_seq rd_seq;
        rd_seq      = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = addr;
        rd_seq.start(axi_lite_seqr);
        data = rd_seq.data;
    endtask

    task body();
    endtask

endclass
