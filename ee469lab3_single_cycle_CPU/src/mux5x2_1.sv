`timescale 1ns/10ps

module mux5x2_1 (y, x, sel);
    input logic [9:0] x;
    input logic sel;
    output logic [4:0] y;

    genvar i;
    generate
        for (i=0; i<5; i++) begin: mux_block
            mux2_1 mux (.y(y[i]), .x({x[i+5], x[i]}), .sel(sel));
        end
    endgenerate
endmodule


module mux5x2_1_tb ();
    logic [9:0] x;
    logic sel;
    logic [4:0] y;

    mux5x2_1 dut (.*);

    integer i;
    initial begin
        sel = 0;
        x[4:0] = 5'd7;
        x[9:5] = 5'd1;
        #(100);
       
        sel = 1;
        #(100);
    end
endmodule