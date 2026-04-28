class axi_stream_seq_item extends uvm_sequence_item;

    logic [63:0] tdata;
    logic [7:0]  tkeep;
    logic        tlast;

    `uvm_object_utils_begin(axi_stream_seq_item)
        `uvm_field_int(tdata, UVM_ALL_ON)
        `uvm_field_int(tkeep, UVM_ALL_ON)
        `uvm_field_int(tlast, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_stream_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("AXI Stream Beat: data=0x%016h keep=0x%02h last=%0b", tdata, tkeep, tlast);
    endfunction

endclass
