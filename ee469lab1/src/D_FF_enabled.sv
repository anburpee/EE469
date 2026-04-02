// Enabled D flip-flop
module D_FF_enabled (q_enabled, d, reset, clk, en);

    output logic q_enabled; // wire
    input logic d, reset, clk, en;
    logic q; // wire

    D_FF basic_dff (.q(q), .d(d), .reset(reset), .clk(clk));

    and #50 a0 (q_enabled, q, en);
    
endmodule