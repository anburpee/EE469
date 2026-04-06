// Enabled D flip-flop
module D_FF_enabled (q, d, reset, clk, en);

    output logic q; // wire
    input logic d, reset, clk, en;
    logic d_enabled; // wire

    mux2_1 mux (.y(d_enabled), .x({d, q}), .sel(en));
    D_FF basic_dff (.q(q), .d(d_enabled), .reset(reset), .clk(clk));
    
endmodule



module D_FF_enabled_tb();

    logic q;
    logic d, reset, clk, en;

    // dut
    D_FF_enabled dut (.*);

    // simulation clock
    parameter CLOCK_PERIOD = 100;

    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD) clk <= ~clk;
    end

    // stimulus
    initial begin
        reset <= 1; @(posedge clk);
        reset <= 0; 

        d <= 1; en <= 0;   repeat(2) @(posedge clk);
                en <= 1;   repeat(2) @(posedge clk);
        
        d <= 0; en <= 0;   repeat(2) @(posedge clk);
                en <= 1;   repeat(2) @(posedge clk);

        $stop;
    end
endmodule // D_FF_enabled