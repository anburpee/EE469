// 32:1 MUX
// 1-bit output y
// 32 bit input x
// 4 bit input sel
module mux32_1(y, x, sel);

    output logic y;
    input logic [31:0] x;
    input logic [4:0] sel;
    logic [1:0] y_sub; // intermediate outputs from first layer of MUX's

    mux16_1 m0 (.y(y_sub[0]), .x(x[15:0]),  .sel(sel[3:0]));
    mux16_1 m1 (.y(y_sub[1]), .x(x[31:16]), .sel(sel[3:0]));
    mux2_1  m2 (.y(y), .x(y_sub), .sel(sel[4]));

endmodule