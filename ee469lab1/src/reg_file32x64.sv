// 32x64 register file
module reg_file32x64(arr_data_out, arr_data_in, wren, reset, clk);

    localparam int REG_SIZE = 64;
    localparam int NUM_REGS = 32;
    
    output logic [REG_SIZE-1:0] arr_data_out [NUM_REGS-1:0];
    input logic [REG_SIZE-1:0] arr_data_in; // from
    input logic wren, reset, clk;


    // 5:32 decoder



    // generate 32 instances of 64-bit registers
    genvar i;
    generate
        for (i=0; i<NUM_REGS; i++) begin: reg_block
            register64 reg64 (.data_out(arr_data_out[i]), .data_in(arr_data_in), .wren(output to decoder), .reset(reset), .clk(clk));
        end
    endgenerate

    // 32x64:1 multiplexors

endmodule