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


// 3:8 decoder with enable
// y: 8-bit output array
// x: 3-bit input address
// en: 1-bit enable signal
module decoder3_8(y, x, en);

    output logic [7:0] y;
    input logic [2:0] x;
    input logic en;
    logic x2_n, x2, en0, en1, delayed_en;

    not #0.05 n0 (x2_n, x[2]);

    // all three inputs defined simultaneously
    and #0.05 a0 (en0, x2_n, en); 
    and #0.05 a1 (en1, x[2], en);

    decoder2_4 dec0 (.y(y[3:0]), .x(x[1:0]), .en(en0));
    decoder2_4 dec1 (.y(y[7:4]), .x(x[1:0]), .en(en1));
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


// 5:32 decoder with enable
// y: 32-bit output array
// x: 5-bit input address
// en: 1-bit enable signal
module decoder5_32(y, x, en);

    output logic [31:0] y;
    input logic [4:0] x;
    input logic en;
    logic [3:0] en_sub;

    decoder2_4 dec0 (.y(en_sub[3:0]), .x(x[4:3]), .en(en));
    decoder3_8 dec1 (.y(y[7:0]),   .x(x[2:0]), .en(en_sub[0]));
    decoder3_8 dec2 (.y(y[15:8]),  .x(x[2:0]), .en(en_sub[1]));
    decoder3_8 dec3 (.y(y[23:16]), .x(x[2:0]), .en(en_sub[2]));
    decoder3_8 dec4 (.y(y[31:24]), .x(x[2:0]), .en(en_sub[3]));

endmodule //decoder5_32

module decoder5_32_tb();
    parameter INPUT_SIZE = 5;
    logic [2**INPUT_SIZE-1:0] y;
    logic [INPUT_SIZE-1:0] x;
    logic en;
    // dut
    decoder5_32 dut (.*);
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
endmodule // decoder5_32_tb