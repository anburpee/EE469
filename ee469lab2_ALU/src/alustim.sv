// Test bench for ALU
`timescale 1ns/10ps

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

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]	cntrl;
	logic		[63:0]	result;
	logic				negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val; // not sure what this is for
	logic [64:0] untruncated_sum;
	initial begin
	
		$display("%t testing PASS_B operations", $time); // originally said PASS_A (why?)
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);

		////////////Additional Testing//////////////////////////////

		// more addition testing
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		for (i=0; i<20; i++) begin
			A = $random(); B = $random();
			untruncated_sum = {1'b0, A} + {1'b0, B};
			#(delay);
			assert(result == A + B && 
				   carry_out == (untruncated_sum[64]) && 
				   overflow == ((A[63] == B[63]) && (result[63] != A[63])) && 
				   negative == result[63] && 
				   zero == (result == 0));
		end

		// subtraction
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		for (i=0; i<20; i++) begin
			A = $random(); B = $random();
			untruncated_sum = {1'b0, A} + ({1'b0, ~B} +  1); // A - B = A = (~B + 1)
			#(delay);
			assert(result == A - B && 
				   carry_out == (untruncated_sum[64]) && 
				   overflow == ((A[63] != B[63]) && (result[63] != A[63])) && 
				   negative == result[63] && 
				   zero == (result == 0));
		end

		// bitwise AND
		$display("%t testing bitwise AND", $time);
		cntrl = ALU_AND;
		for (i=0; i<20; i++) begin
			A = $random(); B = $random();
			#(delay);
			// assert(result == (A & B) && carry_out == 0 && overflow == 0 && negative == result[63] && zero == (result == 0));
			assert(result == (A & B)) else $error("result issue");
			assert(carry_out == 0) else $error("carry_out issue");
			assert(overflow == 0) else $error("overflow issue");
			assert(negative == result[63]) else $error("negative issue");
			assert(zero == (result == 0)) else $error("zero issue");
		end

		// bitwise OR
		$display("%t testing bitwise OR", $time);
		cntrl = ALU_OR;
		for (i=0; i<20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A | B) && carry_out == 0 && overflow == 0 && negative == result[63] && zero == (result == 0));
		end

		// bitwise XOR
		$display("%t testing bitwise XOR", $time);
		cntrl = ALU_XOR;
		for (i=0; i<20; i++) begin
			A = $random(); B = $random();
			#(delay);
			// assert(result == (A ^ B) && carry_out == 0 && overflow == 0 && negative == result[63] && zero == (result == 0));
			assert(result == (A ^ B)) else $error("result issue");
			assert(carry_out == 0) else $error("carry_out issue");
			assert(overflow == 0) else $error("overflow issue");
			assert(negative == result[63]) else $error("negative issue");
			assert(zero == (result == 0)) else $error("zero issue");
		end


		
	end
endmodule
