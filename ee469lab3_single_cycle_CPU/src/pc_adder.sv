// Dedicated adder for incrementing the program counter by 4 every cycle
module pc_adder (A, sum);
    input logic [63:0] A;
    output logic [63:0] sum;
    logic [63:0] B; // B = 4
    logic [64:0] carry; // carry bits, MSB = last carry-out, LSB = first carry-in

    assign B = 64'd4;
    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i=0; i<64; i++) begin: FA_block
            full_adder fa (.a(A[i]), .b(B[i]), .Cin(carry[i]), .Cout(carry[i+1]), .sum(sum[i]));
        end
    endgenerate
endmodule