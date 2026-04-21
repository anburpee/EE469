// 64-bit register with no enable
module program_counter (clk, reset, data_in, data_out);
    input logic clk;
    input logic [63:0] data_in;
    output logic data_out;

    genvar i;
    generate
        for (i=0; i<64; i++) begin: dff_block
            D_FF dff (.q(data_out[i]), .d(data_in[i]), .reset(reset), .clk(clk));
        end
    endgenerate

endmodule