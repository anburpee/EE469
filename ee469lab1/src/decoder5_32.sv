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
    decoder3_8 dec1 (.y(  y[7:0]), .x(x[2:0]), .en(en_sub[0]));
    decoder3_8 dec2 (.y( y[15:8]), .x(x[2:0]), .en(en_sub[1]));
    decoder3_8 dec3 (.y(y[23:16]), .x(x[2:0]), .en(en_sub[2]));
    decoder3_8 dec4 (.y(y[31:24]), .x(x[2:0]), .en(en_sub[3]));

endmodule
