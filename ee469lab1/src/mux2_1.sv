// 2:1 MUX
// 1-bit output y
// 2 bit input x
// 1 bit input sel
module mux2_1(y, x, sel);

    output logic y;
    input logic [1:0] x;
    input logic sel;
    logic sel_n, follow_x0, follow_x1;

    not #50 n0 (sel_n, sel);
    and #50 a0 (follow_x0, sel_n, x0);
    and #50 a1 (follow_x1, sel, x1);
    or #50 or_gate (y, follow_x0, follow_x1);

endmodule