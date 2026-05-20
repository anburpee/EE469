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