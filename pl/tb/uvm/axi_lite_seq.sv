class axi_lite_write_seq extends uvm_sequence #(axi_lite_seq_item);

    `uvm_object_utils(axi_lite_write_seq)

    logic [31:0] addr;
    logic [31:0] data;

    function new(string name = "axi_lite_write_seq");
        super.new(name);
    endfunction

    task body();
        axi_lite_seq_item req;
        req = axi_lite_seq_item::type_id::create("req");
        start_item(req);
        req.we   = 1;
        req.addr = addr;
        req.data = data;
        finish_item(req);
    endtask

endclass

class axi_lite_read_seq extends uvm_sequence #(axi_lite_seq_item);

    `uvm_object_utils(axi_lite_read_seq)

    logic [31:0] addr;
    logic [31:0] data;

    function new(string name = "axi_lite_read_seq");
        super.new(name);
    endfunction

    task body();
        axi_lite_seq_item req;
        req = axi_lite_seq_item::type_id::create("req");
        start_item(req);
        req.we   = 0;
        req.addr = addr;
        finish_item(req);
        data = req.data;
    endtask

endclass
