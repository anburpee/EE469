// 4:1 MUX
// 1-bit output y
// 4 bit input x
// 2 bit input sel
`timescale 1ns/10ps
module mux4_1(y, x, sel);

    output logic y;
    input logic [3:0] x;
    input logic [1:0] sel;
    logic [1:0] y_sub; // intermediate outputs from m1 and m0 respectively

    mux2_1 m0 (.y(y_sub[0]), .x(x[1:0]), .sel(sel[0]));
    mux2_1 m1 (.y(y_sub[1]), .x(x[3:2]), .sel(sel[0]));
    mux2_1 m2 (.y(y), .x(y_sub), .sel(sel[1]));

endmodule // mux4_1

module mux4_1_tb();

    parameter INPUT_SIZE = 4;

    logic y;
    logic [INPUT_SIZE-1:0] x;
    logic [$clog2(INPUT_SIZE)-1:0] sel;

    // dut
    mux4_1 dut (.*);

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

endmodule // mux4_1_tb