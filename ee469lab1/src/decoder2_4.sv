// Enabled 2:4 decoder 
// y: 4-bit output array
// x: 2-bit input address
// en: 1-bit enable signal
module decoder2_4(y, x, en);

    output logic [3:0] y;
    input logic [1:0] x;
    input logic en;
    logic x1_n, x0_n;

    not #50 n0 (x0_n, x[0]);
    not #50 n1 (x1_n, x[1]);

    and #50 a0 (y[0], x1_n, x0_n, en); // x = 00
    and #50 a1 (y[1], x1_n,  x[0], en); // x = 01
    and #50 a2 (y[2],  x[1], x0_n, en); // x = 10
    and #50 a3 (y[3],  x[1],  x[0], en); // x = 11

endmodule