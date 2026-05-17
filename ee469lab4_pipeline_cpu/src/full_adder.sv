`timescale 1ns/10ps
module full_adder (a, b, Cin, Cout, sum);
    input logic a, b, Cin;
    output logic Cout, sum;
    logic ab, bc, ac;

    // sum
    xor #0.05 (sum, a, b, Cin);

    // carry-out
    and #0.05 (ab, a, b);
    and #0.05 (bc, b, Cin);
    and #0.05 (ac, a, Cin);
    or  #0.05 (Cout, ab, bc, ac);

endmodule



module full_adder_tb();
    logic a, b, Cin;
    logic Cout, sum;

    full_adder dut (.*);

    integer i;
    initial begin
        for (i=0; i<8; i++) begin
            {a, b, Cin} = i;
            #(100);
            $display("a: %0d, b: %0d, Cin: %0d, sum: %0d, Cout: %0d", a, b, Cin, sum, Cout);
        end
    end

endmodule