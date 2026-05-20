// 64-bit comparator to check if input is equal to zero

`timescale 1ps/1ps
module comparator64 (val, comparator_zero);

    input logic [63:0] val;
    output logic comparator_zero;

    genvar i, j;
    generate
        logic [15:0] nor_out;
        logic [3:0]  and_out1;

        for (k=0; k<16; k++) begin // generate sixteen 4-input NOR gates (takes in all 64 bits of result)
                nor #(50) (nor_out[k], result[4*k], result[4*k+1], result[4*k+2], result[4*k+3]);
            end

        for (j=0; j<4; j++) begin
            and #(50) (and_out1[j], nor_out[4*j], nor_out[4*j+1], nor_out[4*j+2], nor_out[4*j+3]);
        end

        and #(50) (zero, and_out1[0], and_out1[1], and_out1[2], and_out1[3]); // top of tree
    endgenerate

endmodule
