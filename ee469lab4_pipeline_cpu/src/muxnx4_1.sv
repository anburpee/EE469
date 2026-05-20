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