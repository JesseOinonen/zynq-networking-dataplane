module clk_gen125MHz (output logic clk);
    initial begin
        clk = 0;
        forever #8ns clk = ~clk; // 125 MHz clock
    end
endmodule

module rst_gen (output logic rst);
    initial begin
        rst = 1;
        #100ns;
        rst = 0;
    end
endmodule
