module clk_gen50MHz (output logic clk);
    initial begin
        clk = 0;
        forever #10ns clk = ~clk; // 50 MHz clock
    end
endmodule

module rst_gen (output logic rst_n);
    initial begin
        rst_n = 0;
        #100ns;
        rst_n = 1;
    end
endmodule
