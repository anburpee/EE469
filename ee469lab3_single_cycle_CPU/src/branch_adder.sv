module branch_adder (A, B, sum);
    input logic [63:0] A, B;
    output logic [63:0] sum;
    logic [64:0] carry; // carry bits, MSB = last carry-out, LSB = first carry-in

    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i=0; i<64; i++) begin: FA_block
            full_adder fa (.a(A[i]), .b(B[i]), .Cin(carry[i]), .Cout(carry[i+1]), .sum(sum[i]));
        end
    endgenerate
endmodule