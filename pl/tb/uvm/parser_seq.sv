class parser_seq extends uvm_sequence #(axi_stream_seq_item);

    `uvm_object_utils(parser_seq)

    function new(string name = "parser_seq");
        super.new(name);
    endfunction

    local task send_beat(logic [63:0] data, logic [7:0] keep, logic last);
        axi_stream_seq_item beat;
        beat       = axi_stream_seq_item::type_id::create("beat");
        start_item(beat);
        beat.tdata = data;
        beat.tkeep = keep;
        beat.tlast = last;
        finish_item(beat);
    endtask

    task body();
        send_beat(64'h025A0605040302DA, 8'hFF,        0);
        send_beat(64'h0045000806050403, 8'hFF,        0);
        send_beat(64'h0640004012342800, 8'hFF,        0);
        send_beat(64'hA8C00101A8C00000, 8'hFF,        0);
        send_beat(64'h00005000D2040201, 8'hFF,        0);
        send_beat(64'h0250000000000100, 8'hFF,        0);
        send_beat(64'h0000000000001072, 8'b00111111,  0);
        send_beat(64'hAAAAAAAAAAAAAAAA, 8'hFF,        0);
        send_beat(64'hBBBBBBBBBBBBBBBB, 8'hFF,        0);
        send_beat(64'hCCCCCCCCCCCCCCCC, 8'hFF,        0);
        send_beat(64'hDDDDDDDDDDDDDDDD, 8'hFF,        0);
        send_beat(64'hEEEEEEEEEEEEEEEE, 8'hFF,        0);
        send_beat(64'hFFFFFFFFFFFFFFFF, 8'hFF,        1);
    endtask

endclass
