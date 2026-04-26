// 2:1 MUX
// 1-bit output y
// 2 bit input x
// 1 bit input sel
`timescale 1ns/10ps
module mux2_1(y, x, sel);

    output logic y;
    input logic [1:0] x;
    input logic sel;
    logic sel_n, follow_x0, follow_x1;

    not #0.05 n0 (sel_n, sel);
    and #0.05 a0 (follow_x0, sel_n, x[0]);
    and #0.05 a1 (follow_x1, sel, x[1]);
    or #0.05 or_gate (y, follow_x0, follow_x1);

endmodule // mux2_1

module mux2_1_tb();

    parameter INPUT_SIZE = 2;

    logic y;
    logic [INPUT_SIZE-1:0] x;
    logic [$clog2(INPUT_SIZE)-1:0] sel;

    // dut
    mux2_1 dut (.*);

    // stimulus
    integer i, j;
    initial begin
        #(100);

        for (i=0; i<INPUT_SIZE; i++) begin
            sel = i;
            for (j=0; j<2**INPUT_SIZE; j++) begin
                x = j; #(100);
            end
        end
        
        $stop;
    end

endmodule // mux2_1_tb