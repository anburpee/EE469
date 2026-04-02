// 4:1 MUX
// 1-bit output y
// 4 bit input x
// 2 bit input sel
module mux4_1(y, x, sel);

    output logic y;
    input logic [3:0] x;
    input logic [1:0] sel;
    logic [1:0] y_sub; // intermediate outputs from m1 and m0 respectively

    mux2_1 m0 (.y(y_sub[0]), .x(x[1:0]), .sel(sel[0]));
    mux2_1 m1 (.y(y_sub[1]), .x(x[3:2]), .sel(sel[0]));
    mux2_1 m2 (.y(y), .x(y_sub), .sel(sel[1]));

endmodule