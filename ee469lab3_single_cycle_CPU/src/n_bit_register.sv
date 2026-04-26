`timescale 1ns/10ps

// 64-bit register with no enable
module n_bit_register #(parameter NUM_BITS=64) (clk, reset, en, data_in, data_out);
    input logic clk, reset, en;
    input logic [NUM_BITS-1:0] data_in;
    output logic [NUM_BITS-1:0] data_out;

    genvar i;
    generate
        for (i=0; i<NUM_BITS; i++) begin: dff_block
            D_FF_enabled dff (.q(data_out[i]), .d(data_in[i]), .reset(reset), .clk(clk), .en(en));
        end
    endgenerate

endmodule