// 16:1 MUX
// 1-bit output y
// 16 bit input x
// 4 bit input sel
`timescale 1ns/10ps
module mux16_1(y, x, sel);

    output logic y;
    input logic [15:0] x;
    input logic [3:0] sel;
    logic [3:0] y_sub; // intermediate outputs from first layer of MUX's

    mux4_1 m0 (.y(y_sub[0]), .x(x[3:0]),   .sel(sel[1:0]));
    mux4_1 m1 (.y(y_sub[1]), .x(x[7:4]),   .sel(sel[1:0]));
    mux4_1 m2 (.y(y_sub[2]), .x(x[11:8]),  .sel(sel[1:0]));
    mux4_1 m3 (.y(y_sub[3]), .x(x[15:12]), .sel(sel[1:0]));
    mux4_1 m4 (.y(y), .x(y_sub), .sel(sel[3:2]));

endmodule // mux16_1


module mux16_1_tb();

    parameter INPUT_SIZE = 16;

    logic y;
    logic [INPUT_SIZE-1:0] x;
    logic [$clog2(INPUT_SIZE)-1:0] sel;

    // dut
    mux16_1 dut (.*);

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

endmodule // mux16_1_tb