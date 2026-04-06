// 32:1 MUX
// 1-bit output y
// 32 bit input x
// 4 bit input sel
`timescale 1ns/10ps
module mux32_1(y, x, sel);

    output logic y;
    input logic [31:0] x;
    input logic [4:0] sel;
    logic [1:0] y_sub; // intermediate outputs from first layer of MUX's

    mux16_1 m0 (.y(y_sub[0]), .x(x[15:0]),  .sel(sel[3:0]));
    mux16_1 m1 (.y(y_sub[1]), .x(x[31:16]), .sel(sel[3:0]));
    mux2_1  m2 (.y(y), .x(y_sub), .sel(sel[4]));

endmodule //mux32_1

module mux32_1_tb();

    parameter INPUT_SIZE = 32;

    logic y;
    logic [INPUT_SIZE-1:0] x;
    logic [$clog2(INPUT_SIZE)-1:0] sel;

    // dut
    mux32_1 dut (.*);

    // stimulus
    integer i, j;
    initial begin
        #(100);

        for (i=0; i<INPUT_SIZE; i++) begin
            sel = i;
            x = 0;
            x[i] = 1'b1; #(100);
            x = 0; #(2000);
        end
        
        $stop;
    end

endmodule // mux32_1_tb