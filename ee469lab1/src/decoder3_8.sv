// 3:8 decoder with enable
// y: 8-bit output array
// x: 3-bit input address
// en: 1-bit enable signal
module decoder3_8(y, x, en);

    output logic [7:0] y;
    input logic [2:0] x;
    input logic en;
    logic x2_n, en0, en1;

    not (x2_n, x[2]);
    and (en0, x2_n, en);
    and (en1,   x2, en);

    decoder2_4 dec0 (.y(y[3:0]), .x(x[1:0]), .en(en0));
    decoder2_4 dec1 (.y(y[7:4]), .x(x[1:0]), .en(en1));

endmodule