// 64 x 32:1 mux, takes 32x64 bit register as input 
// outputs all 64 bits stored in the selected register

`timescale 1ns/10ps
module mux64_32_1 (y, x, sel);
    output logic [63:0] y;
    input logic [31:0][63:0] x; // connect to 32x64 bit register
    input logic [4:0] sel;
	logic [63:0][31:0] temp_flipped_x; // 64 rows, 32 cols
    
    genvar i, j;
    generate
        // mux_block[0] chooses between the 0th bit of all 32 registers
        // mux_block[63] chooses between the 63rd bit of all 32 registers
        // [4:0] sel in each of the 32:1 MUX's chooses which register's bit (register 0-31) to output
        for (i=0; i<64; i++) begin: mux_block //for every bit
            for (j=0; j<32; j++) begin
                            //[row][col]
                assign temp_flipped_x[i][j] = x[j][i]; // flip the array
            end
                                // x[i][63:0]
                                // indexing the ith bit of each of the 64-bit registers
            mux32_1 mux32x1 (.y(y[i]), .x(temp_flipped_x[i]), .sel(sel)); 
        end
    endgenerate
endmodule // mux64_32_1

// 64x(32:1) multiplexors (in charge of reading operations)
    // generate 
    //         for (j=0; j<64; j++) begin: mux_block     // all regs, at bit j
    //             mux32_1 mux32a (.y(ReadData1[j]), .x({1'b0,
    //                                                 reg_out[30][j],
    //                                                 reg_out[29][j],
    //                                                 reg_out[28][j],
    //                                                 reg_out[27][j],
    //                                                 reg_out[26][j],
    //                                                 reg_out[25][j],
    //                                                 reg_out[24][j],
    //                                                 reg_out[23][j],
    //                                                 reg_out[22][j],
    //                                                 reg_out[21][j],
    //                                                 reg_out[20][j],
    //                                                 reg_out[19][j],
    //                                                 reg_out[18][j],
    //                                                 reg_out[17][j],
    //                                                 reg_out[16][j],
    //                                                 reg_out[15][j],
    //                                                 reg_out[14][j],
    //                                                 reg_out[13][j],
    //                                                 reg_out[12][j],
    //                                                 reg_out[11][j],
    //                                                 reg_out[10][j],
    //                                                 reg_out[9][j],
    //                                                 reg_out[8][j],
    //                                                 reg_out[7][j],
    //                                                 reg_out[6][j],
    //                                                 reg_out[5][j],
    //                                                 reg_out[4][j],
    //                                                 reg_out[3][j],
    //                                                 reg_out[2][j],
    //                                                 reg_out[1][j],
    //                                                 reg_out[0][j]}), .sel(ReadRegister1));    

    //             mux32_1 mux32b (.y(ReadData2[j]), .x({1'b0,
    //                                                 reg_out[30][j],
    //                                                 reg_out[29][j],
    //                                                 reg_out[28][j],
    //                                                 reg_out[27][j],
    //                                                 reg_out[26][j],
    //                                                 reg_out[25][j],
    //                                                 reg_out[24][j],
    //                                                 reg_out[23][j],
    //                                                 reg_out[22][j],
    //                                                 reg_out[21][j],
    //                                                 reg_out[20][j],
    //                                                 reg_out[19][j],
    //                                                 reg_out[18][j],
    //                                                 reg_out[17][j],
    //                                                 reg_out[16][j],
    //                                                 reg_out[15][j],
    //                                                 reg_out[14][j],
    //                                                 reg_out[13][j],
    //                                                 reg_out[12][j],
    //                                                 reg_out[11][j],
    //                                                 reg_out[10][j],
    //                                                 reg_out[9][j],
    //                                                 reg_out[8][j],
    //                                                 reg_out[7][j],
    //                                                 reg_out[6][j],
    //                                                 reg_out[5][j],
    //                                                 reg_out[4][j],
    //                                                 reg_out[3][j],
    //                                                 reg_out[2][j],
    //                                                 reg_out[1][j],
    //                                                 reg_out[0][j]}), .sel(ReadRegister2));
    //         end
    // endgenerate              

module mux64_32_1_tb();
    logic [63:0] y;
    logic [31:0][63:0] x; 
    logic [4:0] sel;

    // dut
    mux64_32_1 dut (.*);

    // stimulus
    integer i, j;
    initial begin
        #(100);

    // for each 64-bit register, drive those 64 bits high for 100 time units
    // before setting them back to 0.
    // output y should follow the pulse after a time delay
    for (i=0; i<32; i++) begin 
        sel = i;
        x = 0;
        x[i] = 2*(i+1); #(500);
        x = 0; #(2000);
        end
    end
        

endmodule // mux64_32_1_tb