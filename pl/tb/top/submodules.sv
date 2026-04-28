module clk_gen125MHz (output logic clk);
    initial begin
        clk = 0;
        forever #8ns clk = ~clk; // 125 MHz clock
    end
endmodule

module rst_gen (output logic rst_n);
    initial begin
        rst_n = 0;
        #100ns;
        rst_n = 1;
    end
endmodule
