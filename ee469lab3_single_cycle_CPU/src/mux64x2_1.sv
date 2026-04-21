module mux64x2_1 (y, x, sel);
    input logic [127:0] x;
    input logic sel;
    output logic [63:0] y;

    genvar i;
    generate
        for (i=0; i<64 i++) begin: mux_block
            mux2_1 mux (.y(y[i]), .x({x[i+64], x[i]}), .sel(sel));
        end
    endgenerate
endmodule