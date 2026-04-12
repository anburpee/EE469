// 5:32 decoder with enable
// y: 32-bit output array
// x: 5-bit input address
// en: 1-bit enable signal
`timescale 1ns/10ps
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

    // output logic [31:0] y;
    // input logic [4:0] x;
    // input logic en;
    // logic [3:0] en_sub;
    // logic [2:0] delay1_x_lsb, delay2_x_lsb;

    // // match timing to get rid of glitches
    // buf #50 b0 (delay1_x_lsb[0], x[0]);
    // buf #50 b1 (delay1_x_lsb[1], x[1]);
    // buf #50 b2 (delay1_x_lsb[2], x[2]);

    // buf #50 b3 (delay2_x_lsb[0], delay1_x_lsb[0]);
    // buf #50 b4 (delay2_x_lsb[1], delay1_x_lsb[1]);
    // buf #50 b5 (delay2_x_lsb[2], delay1_x_lsb[2]);

    // decoder2_4 dec0 (.y(en_sub[3:0]), .x(x[4:3]), .en(en));
    // decoder3_8 dec1 (.y(y[7:0]),   .x(delay2_x_lsb), .en(en_sub[0]));
    // decoder3_8 dec2 (.y(y[15:8]),  .x(delay2_x_lsb), .en(en_sub[1]));
    // decoder3_8 dec3 (.y(y[23:16]), .x(delay2_x_lsb), .en(en_sub[2]));
    // decoder3_8 dec4 (.y(y[31:24]), .x(delay2_x_lsb), .en(en_sub[3]));

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