// 3:8 decoder with enable
// y: 8-bit output array
// x: 3-bit input address
// en: 1-bit enable signal
`timescale 1ns/10ps
module decoder3_8(y, x, en);

    output logic [7:0] y;
    input logic [2:0] x;
    input logic en;
    logic x2_n, x2, en0, en1, delayed_en;

    not (x2_n, x[2]);

    // all three inputs defined simultaneously
    and (en0, x2_n, en); 
    and (en1, x[2], en);

    decoder2_4 dec0 (.y(y[3:0]), .x(x[1:0]), .en(en0));
    decoder2_4 dec1 (.y(y[7:4]), .x(x[1:0]), .en(en1));

    // output logic [7:0] y;
    // input logic [2:0] x;
    // input logic en;
    // logic x2_n, x2, en0, en1, delayed_en;

    // not (x2_n, x[2]);
    // buf (x2, x[2]);
    // buf (delayed_en, en); 

    // // all three inputs defined simultaneously
    // and (en0, x2_n, delayed_en); 
    // and (en1,   x2, delayed_en);

    // decoder2_4 dec0 (.y(y[3:0]), .x(x[1:0]), .en(en0));
    // decoder2_4 dec1 (.y(y[7:4]), .x(x[1:0]), .en(en1));

endmodule //decoder3_8


module decoder3_8_tb();

    parameter INPUT_SIZE = 3;

    logic [2**INPUT_SIZE-1:0] y;
    logic [INPUT_SIZE-1:0] x;
    logic en;

    // dut
    decoder3_8 dut (.*);

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

endmodule // decoder3_8_tb