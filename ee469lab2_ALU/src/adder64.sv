// 64-bit adder

// A: 64-bit addend1
// B: 64-bit addend2
// Cin: 1-bit initial carry-in
// sum: 64-bit sum of A and B
// Cout: flags if the addition results in a carry-out
// overflow: flags if the addition results in overflow
`timescale 1ns/10ps
module adder64 (A, B, initial_Cin, sum, Cout, overflow);
    input logic [63:0] A, B;
    input logic initial_Cin; // functions as initial carry-in & indicates whether addition or subtraction is performed
    output logic [63:0] sum;
    output logic Cout, overflow; // flags
    logic [64:0] carry_arr; // includes initial carry-in (LSB) and final carry-out (MSB)

    assign carry_arr[0] = initial_Cin;
    assign Cout = carry_arr[64];

    xor #0.05 (overflow, carry_arr[64], carry_arr[63]);

    genvar i;
    generate
        logic [63:0] B_xor; // B_xor = B if addition, ~(B) if subtraction
        for (i=0; i<64; i++) begin : adder_block
            xor #0.05 (B_xor[i], B[i], initial_Cin);
            full_adder fa (.a(A[i]), .b(B_xor[i]), .Cin(carry_arr[i]), .Cout(carry_arr[i+1]), .sum(sum[i]));
        end
    endgenerate

endmodule

module adder64_tb();
    logic [63:0] A, B;
    logic initial_Cin; // functions as initial carry-in & indicates whether addition or subtraction is performed
    logic [63:0] sum;
    logic Cout, overflow; // flags

    adder64 dut (.*);

    integer i;
    initial begin
        // addition
        $display("Addition");
        initial_Cin = 0;
        for (i=0; i<10; i++) begin
            A = i;
            B = i+1;
            #(100);
            $display("A: %0d, B: %0d, carry-in, %d, carry_out: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, dut.carry_arr[i], dut.carry_arr[i+1], sum, Cout, overflow);
        end

        // carry-out check
        A = 64'hFFFFFFFFFFFFFFFF;  B = 64'h1;  #(100); 
        $display("A: %0d, B: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, sum, Cout, overflow);
        // overflow check
        A = 64'h7FFFFFFFFFFFFFFF;  B = 64'h1;  #(100); // largest two's comp number + 1
        $display("A: %0d, B: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, sum, Cout, overflow);
        

        $display("Subtraction");
        // subtraction:
        initial_Cin = 1;
        for (i=0; i<10; i++) begin
            A = i+1;
            B = i;
            #(100);
            $display("A: %0d, B: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, sum, Cout, overflow);
        end

        // carry-out check
        A = 64'h7FFFFFFFFFFFFFFF;  B = 64'h0;  #(100); //
        $display("A: %0d, B: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, sum, Cout, overflow);
        // overflow check
        A = 64'h7FFFFFFFFFFFFFFF;  B = 64'hFFFFFFFFFFFFFFFF;  #(100); // -2^63 - 1
        $display("A: %0d, B: %0d, sum: %0d, FLAGS -- Cout: %0b, overflow: %0b", 
                      A, B, sum, Cout, overflow);
    end

endmodule