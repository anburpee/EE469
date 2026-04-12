// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
`timescale 1ns/10ps
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
    input logic		[63:0]	A, B;
	input logic		[2:0]	cntrl;
	output logic	[63:0]	result;
	output logic			negative, zero, overflow, carry_out;
    logic           [63:0]  adder_out;

    adder64 adder (.A(A), .B(B), .initial_Cin(cntrl[0]), .sum(adder_out), .Cout(carry_out), .overflow(overflow));


    genvar i;
    generate
        for (i=0; i<64; i++) begin: mux_block
            and #(0.05) (and_out, A[i], B[i]);
            or  #(0.05) (or_out,  A[i], B[i]);
            xor #(0.05) (xor_out, A[i], B[i]);
            mux8_1 mux8 (.y(result[i]), .x({xor_out, 1'bZ, or_out, and_out, adder_out[i], adder_out[i], 1'bZ, B[i]}), .sel(cntrl));
        end
    endgenerate

    // negative = MSB of result is 1 (MSB of result or just adder_out??? -- does negative matter in cases other than addition/subtraction?)
    assign negative = result[63];

    // zero = (result == 64'd0)
    genvar j, k;
    generate
        logic [15:0] nor_out;
        logic [3:0]  and_out;

        for (k=0; k<16; k++) begin // generate sixteen 4-input NOR gates (takes in all 64 bits of result)
                nor #(0.05) (nor_out[k], result[k], result[k+1], result[k+2], result[k+3]);
            end

        for (j=0; j<4; j++) begin: zero_flag_gates
            and #(0.05) (and_out[j], nor_out[j], nor_out[j+1], nor_out[j+2], nor_out[j+3]);
        end

        and #(0.05) (zero, and_out[0], and_out[1], and_out[2], and_out[3]); // top of tree

    endgenerate

endmodule
