// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 	

	parameter ClockDelay = 5000;

	logic  [4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadRegister1, .ReadRegister2, .WriteRegister, .WriteData, .RegWrite, .clk, .ReadData1, .ReadData2);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1; // read new values from the writes in this loop
			ReadRegister2 <= i; // should read old values
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end

		// see what happens if ReadRegister1 is written to and read from at the same time
		$display("%t Write and read to the same registers at the same time", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 1;
			ReadRegister1 <= i;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i+1;
			@(posedge clk);
			$display("WriteData: %0d, ReadRegister1: %0d, ReadData1: %0d, ReadRegister2: %0d, ReadData2: %0d", WriteData, ReadRegister1, ReadData1, ReadRegister2, ReadData2);
		end

		// RegWrite off
		$display("%t Write and read to the same registers at the same time", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 1;
			ReadRegister1 <= i;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i+1;
			@(posedge clk);
			$display("WriteData: %0d, ReadRegister1: %0d, ReadData1: %0d, ReadRegister2: %0d, ReadData2: %0d", WriteData, ReadRegister1, ReadData1, ReadRegister2, ReadData2);
		end

		$stop;
	end
endmodule
