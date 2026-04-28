class axi_lite_seq_item extends uvm_sequence_item;

    logic [31:0] addr;
    logic [31:0] data;
    logic        we;

    `uvm_object_utils_begin(axi_lite_seq_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(we,   UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_lite_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("AXI Lite Transaction: %s, Addr: 0x%08h, Data: 0x%08h", 
                         we ? "WRITE" : "READ", addr, data);
    endfunction
endclass