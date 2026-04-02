// 64 bit register with reset and write enable
module register64(data_out, data_in, wren, reset, clk);

    localparam int REG_SIZE = 64;
    
    output logic [REG_SIZE-1:0] data_out;
    input logic [REG_SIZE-1:0] data_in;
    input logic wren, reset, clk;

    genvar i;
    generate
        for (i=0; i<REG_SIZE; i++) begin: dff_block
            D_FF_enabled en_dff (.q_enabled(data_out[i]), .d(data_in[i]), .reset(reset), .clk(clk), .en(wren));
        end
    endgenerate

endmodule