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


// 4:1 MUX
// 1-bit output y
// 4 bit input x
// 2 bit input sel
module mux8_1 (y, x, sel);

    output logic y;
    input logic [7:0] x;
    input logic [2:0] sel;
    logic [1:0] y_sub; // intermediate outputs from m1 and m0 respectively

    mux4_1 m0 (.y(y_sub[0]), .x(x[3:0]), .sel(sel[1:0]));
    mux4_1 m1 (.y(y_sub[1]), .x(x[7:4]), .sel(sel[1:0]));
    mux2_1 m2 (.y(y), .x(y_sub), .sel(sel[2]));

endmodule // mux8_1

module mux8_1_tb();
    parameter INPUT_SIZE = 8;
    logic y;
    logic [INPUT_SIZE-1:0] x;
    logic [$clog2(INPUT_SIZE)-1:0] sel;
    // dut
    mux8_1 dut (.*);
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
endmodule // mux8_1_tb


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
    // long-ass testbench
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
            x[i] = 1'b1; #(100); // drive the selected input high for 100 time units
                                 // expected behavior: after a time delay, output should go high for the same amout of time the input was high for
            x = 0; #(2000); // set everything back to zero
        end
        $stop;
    end
endmodule // mux32_1_tb



module muxnx2_1 #(parameter N=64) (y, x, sel);
    input logic [N*2-1:0] x;
    input logic sel;
    output logic [N-1:0] y;

    genvar i;
    generate
        for (i=0; i<N; i++) begin: mux_block
            mux2_1 mux (.y(y[i]), .x({x[i+N], x[i]}), .sel(sel));
        end
    endgenerate
endmodule


module muxnx4_1 #(parameter N=64) (y, x, sel);
    input logic [N*4-1:0] x;
    input logic [1:0] sel;
    output logic [N-1:0] y;

    genvar i;
    generate
        for (i=0; i<N; i++) begin: mux_block
            mux4_1 mux (.y(y[i]), .x({x[i+3*N], x[i+2*N], x[i+N], x[i]}), .sel(sel));
        end
    endgenerate
endmodule