// Enabled 2:4 decoder 
// y: 4-bit output array
// x: 2-bit input address
// en: 1-bit enable signal
`timescale 1ns/10ps
module decoder2_4(y, x, en);

    output logic [3:0] y;
    input logic [1:0] x;
    input logic en;
    logic x1_n, x0_n;

    not #0.05 n0 (x0_n, x[0]);
    not #0.05 n1 (x1_n, x[1]);

    and #0.05 a0 (y[0], x1_n, x0_n, en); // x = 00
    and #0.05 a1 (y[1], x1_n, x[0], en); // x = 01
    and #0.05 a2 (y[2], x[1], x0_n, en); // x = 10
    and #0.05 a3 (y[3], x[1], x[0], en); // x = 11

    // output logic [3:0] y;
    // input logic [1:0] x;
    // input logic en;
    // logic x1_n, x0_n, x1, x0, delayed_en;

    // not #50 n0 (x0_n, x[0]);
    // not #50 n1 (x1_n, x[1]);
    // buf #50 b0 (x0, x[0]);
    // buf #50 b1 (x1, x[1]);

    // buf #50 b2 (delayed_en, en);

    // and #50 a0 (y[0], x1_n, x0_n, delayed_en); // x = 00
    // and #50 a1 (y[1], x1_n, x0,   delayed_en); // x = 01
    // and #50 a2 (y[2], x1,   x0_n, delayed_en); // x = 10
    // and #50 a3 (y[3], x1,   x0,   delayed_en); // x = 11

endmodule //decoder2_4


module decoder2_4_tb();

    parameter INPUT_SIZE = 2;

    logic [2**INPUT_SIZE-1:0] y;
    logic [INPUT_SIZE-1:0] x;
    logic en;

    // dut
    decoder2_4 dut (.*);

    // stimulus
    integer i;
    initial begin

        en = 0;
        for (i=0; i<2**INPUT_SIZE; i++) begin
            x = i; #(200);
        end

        en = 1;
        for (i=0; i<2**INPUT_SIZE; i++) begin
            x = i; #(200);
        end

        $stop;
    end

endmodule // decoder2_4_tb