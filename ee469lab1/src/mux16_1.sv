// 16:1 MUX
// 1-bit output y
// 16 bit input x
// 4 bit input sel
module mux16_1(y, x, sel);

    output logic y;
    input logic [15:0] x;
    input logic [3:0] sel;
    logic [3:0] y_sub; // intermediate outputs from first layer of MUX's

    mux4_1 m0 (.y(y_sub[0]), .x(x[3:0]),   .sel(sel[1:0]));
    mux4_1 m1 (.y(y_sub[1]), .x(x[7:4]),   .sel(sel[1:0]));
    mux4_1 m2 (.y(y_sub[1]), .x(x[11:8]),  .sel(sel[1:0]));
    mux4_1 m3 (.y(y_sub[1]), .x(x[15:12]), .sel(sel[1:0]));
    mux4_1 m4 (.y(y), .x(y_sub), .sel(sel[3:2]));

endmodule