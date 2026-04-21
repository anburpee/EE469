module mux5x2_1 (y, x, sel);
    input logic [9:0] x;
    input logic sel;
    output logic [4:0] y;

    genvar i;
    generate
        for (i=0; i<5 i++) begin: mux_block
            mux2_1 mux (.y(y[i]), .x({x[i+5], x[i]}), .sel(sel));
        end
    endgenerate
endmodule