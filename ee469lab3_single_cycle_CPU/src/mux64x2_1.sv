`timescale 1ns/10ps

module mux64x2_1 (y, x, sel);
    input logic [127:0] x;
    input logic sel;
    output logic [63:0] y;

    genvar i;
    generate
        for (i=0; i<64; i++) begin: mux_block
            mux2_1 mux (.y(y[i]), .x({x[i+64], x[i]}), .sel(sel));
        end
    endgenerate
endmodule

module mux64x2_1_tb ();
    logic [127:0] x;
    logic sel;
    logic [63:0] y;

    mux64x2_1 dut (.*);

    integer i;
    initial begin
        sel = 0;
        x[63:0] = 64'd63;
        x[127:64] = 64'd1;
        #(100);
       
        sel = 1;
        #(100);
    
    end
endmodule
