// A full memory hierarchy. 
//
// Parameter:
// MODEL_NUMBER: A number used to specify a specific instance of the memory.  Different numbers give different hierarchies and settings.
//   This should be set to your student ID number.
// DMEM_ADDRESS_WIDTH: The number of bits of address for the memory.  Sets the total capacity of main memory.
//
// Accesses: To do an access, set address, data_in, byte_access, and write to a desired value, and set start_access to 1.
//   All these signals must be held constant until access_done, at which point the operation is completed.  On a read,
//   data_out will be set to the correct data for the single cycle when access_done is true.  Note that you can do
//   back-to-back accesses - when access_done is true, if you keep start_access true the memory will start the next access.
// 
//   When start_access = 0, the other input values do not matter.
//   bytemask controls which bytes are actually written (ignored on a read).
//     If bytemask[i] == 1, we do write the byte from data_in[8*i+7 : 8*i] to memory at the corresponding position.  If == 0, that byte not written.
//   To do a read: write = 0,  data_in does not matter.  data_out will have the proper data for the single cycle where access_done==1.
//   On a write, write = 1 and data_in must have the data to write.
//
//   Addresses must be aligned.  Since this is a 64-bit memory (8 bytes), the bottom 3 bits of each address must be 0.
//
//   It is an error to set start_access to 1 and then either set start_access to 0 or change any other input before access_done = 1.
//
//   Accessor tasks (essentially subroutines for testbenches) are provided below to help do most kinds of accesses.

// Line to set up the timing of simulation: says units to use are ns, and smallest resolution is 10ps.
`timescale 1ns/10ps

module lab5 #(parameter [22:0] MODEL_NUMBER = 2462847, parameter DMEM_ADDRESS_WIDTH = 20) (
	// Commands:
	//   (Comes from processor).
	input		logic [DMEM_ADDRESS_WIDTH-1:0]			address,		// The byte address.  Must be word-aligned if byte_access != 1.
	input		logic [63:0]							data_in,		// The data to write.  Ignored on a read.
	input		logic [7:0]								bytemask,		// Only those bytes whose bit is set are written.  Ignored on a read.
	input		logic									write,			// 1 = write, 0 = read.
	input		logic									start_access,	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	output		logic									access_done,	// Set to true on the clock edge that the access is completed.
	output		logic [63:0]							data_out,		// Valid when access_done == 1 and access is a read.
	// Control signals:
	input		logic									clk,
	input		logic									reset			// A reset will invalidate all cache entries, and return main memory to the default initial values.
); 
	
	DataMemory #(.MODEL_NUMBER(MODEL_NUMBER), .DMEM_ADDRESS_WIDTH(DMEM_ADDRESS_WIDTH)) dmem
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset);
	
	always @(posedge clk)
		assert(reset !== 0 || start_access == 0 || address[2:0] == 0); // All accesses must be aligned.
	
endmodule

// Test the data memory, and figure out the settings.

module lab5_testbench ();
	localparam USERID = 2462847;  // Set to your student ID #
	localparam ADDRESS_WIDTH = 20;
	localparam DATA_WIDTH = 8;
	
	logic [ADDRESS_WIDTH-1:0]			address;		// The byte address.  Must be word-aligned if byte_access != 1.
	logic [63:0]						data_in;		// The data to write.  Ignored on a read.
	logic [7:0]							bytemask;		// Only those bytes whose bit is set are written.  Ignored on a read.
	logic								write;			// 1 = write, 0 = read.
	logic								start_access;	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	logic								access_done;	// Set to true on the clock edge that the access is completed.
	logic	[63:0]						data_out;		// Valid when access_done == 1 and access is a read.
	// Control signals:
	logic								clk;
	logic								reset;				// A reset will invalidate all cache entries, and return main memory to the default initial values.

	lab5 #(.MODEL_NUMBER(USERID), .DMEM_ADDRESS_WIDTH(ADDRESS_WIDTH)) dut
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset); 

	// Set up the clock.
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 5, " ns", 10);

	// --- Keep track of number of clock cycles, for statistics.
	integer cycles;
	always @(posedge clk) begin
		if (reset)
			cycles <= 0;
		else
			cycles <= cycles + 1;
	end
		
	// --- Tasks are subroutines for doing various operations.  These provide read and write actions.
	
	// Set memory controls to an idle state, no accesses going.
	task mem_idle;
		address			<= 'x;
		data_in			<= 'x;
		bytemask		<= 'x;
		write			<= 'x;
		start_access	<= 0;
		#1;
	endtask
	
	// Perform a read, and return the resulting data in the read_data output.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task readMem;
		input	[ADDRESS_WIDTH-1:0]			read_addr;
		output	[DATA_WIDTH-1:0][7:0]		read_data;
		output	int							delay;		// Access time actually seen.
		
		int startTime, endTime;
		
		startTime = cycles;
		address			<= read_addr;
		data_in			<= 'x;
		bytemask		<= 'x;
		write			<= 0;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		read_data = data_out;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	function int min;
		input int x;
		input int y;
		
		min = ((x<y) ? x : y);
	endfunction
	function int max;
		input int x;
		input int y;
		
		max = ((x>y) ? x : y);
	endfunction
	
	// Perform a series of reads, and returns the min and max access times seen.
	// Accesses are at read_addr, read_addr+stride, read_addr+2*stride, ... read_addr+(num_reads-1)*stride.
	task readStride;
		input		[ADDRESS_WIDTH-1:0]		read_addr;
		input		int						stride;
		input		int						num_reads;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]		read_data;
		
		//$display("%t readStride(%d, %d, %d)", $time, read_addr, stride, num_reads);
		readMem(read_addr, read_data, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_reads; i++) begin
			readMem(read_addr+stride*i, read_data, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Perform a write.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task writeMem;
		input [ADDRESS_WIDTH-1:0]			write_address;
		input [DATA_WIDTH-1:0][7:0]			write_data;
		input [DATA_WIDTH-1:0]				write_bytemask;
		output	int							delay;		// Access time actually seen.
		
		int	startTime, endTime;
		
		startTime = cycles;
		address			<= write_address;
		data_in			<= write_data;
		bytemask			<= write_bytemask;
		write				<= 1;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	// Perform a series of writes, and returns the min and max access times seen.
	// Accesses are at write_addr, write_addr+stride, write_addr+2*stride, ... write_addr+(num_writes-1)*stride.
	task writeStride;
		input	[ADDRESS_WIDTH-1:0]			write_addr;
		input	int						    stride;
		input	int							num_writes;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]			write_data;
		
		//$display("%t writeStride(%d, %d, %d)", $time, write_addr, stride, num_writes);
		writeMem(write_addr, write_data, 8'hFF, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_writes; i++) begin
			writeMem(write_addr+stride*i, write_data, 8'hFF, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Skip doing an access for a cycle.
	task noopMem;
		mem_idle();
		@(posedge clk); #1;
	endtask
	
	// Reset the memory.
	task resetMem;
		mem_idle();
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		#1;
	endtask

	// read from start address (inclusive) to end address (exclusive)
	task readSelected;
		input int startVal;
		input int endVal;
		input int stride;
		logic [ADDRESS_WIDTH-1:0]	 read_addr;
		logic [DATA_WIDTH-1:0][7:0]	 read_data;
		int delay;
		int i;
		for (i=startVal; i<endVal; i++) begin 
			read_addr = unsigned'(ADDRESS_WIDTH'(i*stride));
			readMem(read_addr, read_data, delay);
			$display("%d, %t Read took %d cycles. addr: %0d, data: %0d", i, $time, delay, read_addr, int'(read_data));
		end
	endtask

	// write from start address (inclusive) to end address (exclusive)
	// write data = write address
	task writeSelected;
		input int startVal;
		input int endVal;
		input int stride;
		logic [ADDRESS_WIDTH-1:0]	 write_addr;
		logic [DATA_WIDTH-1:0][7:0]	 write_data;
		int delay;
		int i;
		for (i=startVal; i<endVal; i++) begin
			write_addr = unsigned'(ADDRESS_WIDTH'(i*stride)); // *8 to doubleword-align the access.
			write_data = 64'(i*stride);
			writeMem(write_addr, write_data, 8'hFF, delay);
			$display("%d, %t Write took %d cycles. addr: %0d, data: %0d", i, $time, delay, write_addr, int'(write_data));
		end
	endtask

	
	
	logic [DATA_WIDTH-1:0][7:0]		dummy_data;
	logic [ADDRESS_WIDTH-1:0]		addr;
	int	i, delay, minval, maxval;

	// TESTING STARTS HERE
	
	initial begin
		dummy_data <= '0;
		resetMem();				// Initialize the memory.
		
		// // Do 20 random reads.
		// for (i=0; i<100; i++) begin
		// 	addr = $random()*8; // *8 to doubleword-align the access.
		// 	readMem(addr, dummy_data, delay);
		// 	$display("%d, %t Read took %d cycles", i, $time, delay);
		// end
		
		// // Do 5 random double-word writes of random data.
		// for (i=0; i<5; i++) begin
		// 	addr = $random()*8; // *8 to doubleword-align the access.
		// 	dummy_data = $random();
		// 	writeMem(addr, dummy_data, 8'hFF, delay);
		// 	$display("%d, %t Write took %d cycles", i, $time, delay);
		// end

		//---------READ PARAMETERS----------------------------------------------------------------------------------------------

		// // figure out number of L1 blocks------------------
		// readSelected(0, 8, 16);
		// // re-read
		// readSelected(0, 8, 16);

		// // figure out L1 associativity---------------------
		// resetMem();				// Initialize the memory.
		// readSelected(0, 4, 16);
		// readSelected(8, 12, 16);
		// // if hit time for this is all L2 hit time, then cache is direct-mapped
		// readSelected(0, 4, 16);

		// //  figure out L2 blocksize--------------------------------
		// readSelected(0, 8*4, 16); // read from n*(number of blocks in L1 cache) --- overwrites n-1 times
		// // since the hit time for every read is the L2 hit time, the blocksize for L2 must be the same as L1 (16 bytes)
		// // capacity = 16*8*4 bytes = 512 bytes
		// // if blocksize was larger, then for each L1 cache miss L2 would have loaded more than 16 bytes to L1, 
		// // meaning hit time for the next set of addresses would have been L1 hit time (since it was loaded from L2 to L1 during the previous read)
		// readSelected(0, 8*4, 16); // read overwritten content (should access L2 cache)
		// resetMem();
		// readSelected(0, 8*5, 16); // read from n*(number of blocks in L1 cache) --- overwrites n-1 times
		// readSelected(8*4, 8*5, 16); // read content currently in L1
		// readSelected(0, 8*4, 16) // read overwritten content (should access L2 cache)

		// figure out L2 associativity---------------------------------
		// readSelected(0, 8, 16); // fill entire L1 cache (fills a quarter of L2 cache: addresses 0-7)
		// readSelected(8*4, 8*5, 16); // overwrite L1 cache -- if L2 is direct-mapped, overwrites L2 as well
		// // read addresses 0-7: if hit time = main memory hit time, L2 is direct mapped
		// // if hit time = L2 hit time, L2 is N-way set associative
		// // UPDATE: hit time was all L2 hit time, so not direct mapped
		// readSelected(0, 8, 16);
		// // continue reading to figure out set associativity: 0-7 already in L1 and L2 cache
		// readSelected(8*2, 8*3, 16);
		// readSelected(8*4, 8*5, 16); // overwrite L1 cache -- if L2 is direct-mapped, overwrites L2 as well
		// readSelected(8*6, 4*7, 16); 
		// // re-read
		// readSelected(0, 8, 16);
		// readSelected(8*2, 8*3, 16);
		// readSelected(8*4, 8*5, 16);
		// readSelected(8*6, 4*7, 16); // UPDATE: all L2 hit time for reads above, so at least 4-way set associative

		// // is it 4-way set associative?
		// resetMem();
		// readSelected(0, 4, 16);
		// readSelected(4*2, 4*3, 16);
		// readSelected(4*4, 4*5, 16);
		// readSelected(4*6, 4*7, 16);
		// readSelected(4*8, 4*9, 16); // overwriting if 4-way set associative
		// readSelected(4*10, 4*11, 16);
		// readSelected(4*12, 4*13, 16);
		// readSelected(4*14, 4*15, 16);
		// // re-read
		// readSelected(0, 4, 16);
		// readSelected(4*2, 4*3, 16);
		// readSelected(4*4, 4*5, 16);
		// readSelected(4*6, 4*7, 16);
		// readSelected(4*8, 4*9, 16);
		// readSelected(4*10, 4*11, 16);
		// readSelected(4*12, 4*13, 16);
		// readSelected(4*14, 4*15, 16); // hit time was all L2 hit time --> at least 8 way set associative

		// // is it 8-way set associative?
		// resetMem();
		// readSelected(0, 2, 16);
		// readSelected(2*2, 2*3, 16);
		// readSelected(2*4, 2*5, 16);
		// readSelected(2*6, 2*7, 16);
		// readSelected(2*8, 2*9, 16); 
		// readSelected(2*10, 2*11, 16);
		// readSelected(2*12, 2*13, 16);
		// readSelected(2*14, 2*15, 16);
		// readSelected(2*16, 2*17, 16); // overwriting if 8-way set associative
		// // readSelected(2*18, 2*19, 16);
		// // readSelected(2*20, 2*21, 16);
		// // readSelected(2*22, 2*23, 16);
		// // readSelected(2*24, 2*25, 16); 
		// // readSelected(2*26, 2*27, 16);
		// // readSelected(2*28, 2*29, 16);
		// // re-read
		// readSelected(0, 2, 16);
		// readSelected(2*2, 2*3, 16);
		// readSelected(2*4, 2*5, 16);
		// readSelected(2*6, 2*7, 16);
		// readSelected(2*8, 2*9, 16); 
		// readSelected(2*10, 2*11, 16);
		// readSelected(2*12, 2*13, 16);
		// readSelected(2*14, 2*15, 16);
		// readSelected(2*16, 2*17, 16);
		// // readSelected(2*18, 2*19, 16);
		// // readSelected(2*20, 2*21, 16);
		// // readSelected(2*22, 2*23, 16);
		// // readSelected(2*24, 2*25, 16); 
		// // readSelected(2*26, 2*27, 16);
		// // readSelected(2*28, 2*29, 16); // hit time started to deviate from being all L2 hit times starting from 9th horiz. block read -> 8-way set associative
		// 								 // also: not LRU since if it were to be LRU addresses 0,1 would have been evicted first, but 0,1 still had L2 hit time

		//---------	WRITE PARAMETERS--------------------------------------------------------------------------------------------------

		// // figure out L1 write policy----------------------------------
		// // populate L2 to full capacity
		// readSelected(0, 8*4, 16); 
		
		// writeSelected(8*3, 8*4, 16); // L1 cache hit - written to at least L1
		// readSelected(8*3, 8*4, 16); // L1 cache hit - should take l1 hit time (3 cycles each)
		
		// // L1 cache miss -> new data written to L1 is evicted, and needs to be written to L2.
		// // Since L1 has write-back policy, if no write buffer, each read should take significant amount of extra time to
		// // write back to L2 before read happens.
		// // If there is a write buffer, first read would take less time than the rest
		// readSelected(8*0, 8*1, 16); // UPDATE: all evictions + reads are uniform (20 cycles), so no write buffer


		// figure out L2 write policy----------------------------------
		// populate L2 to full capacity
		// readSelected(0, 8*4, 16); 
		
		// writeSelected(8*0, 8*4, 16); // L1 cache miss, L2 cache hit - written to at least L2
		// readSelected(8*0, 8*4, 16); // L2 cache hit - should take L1 hit time (11 cycles each)
		// 													 // -- except for first 8 cuz L1 writes need to get evicted and written back to L2 first
		// readSelected(8*4, 8*8, 16);



		// writeSelected(0, 8, 16); // L1 cache miss

		// for (i=0; i<20; i++) begin
		// 	readSelected(8*3, 8*3+1, 16); 
		// end
		// writeSelected(0, 1, 16); // L1 cache miss - written to L2


		// figure out if there's an L3 cache---------------------------
		readSelected(0, 8*5, 16); 
		readSelected(0, 8*5, 16); // only L2 and main memory retreival times -> no L3 cache


		// Reset the memory.
		resetMem();
		
		// Read all of the first KB
		readStride(0, 16, 1024/8, minval, maxval);
		$display("%t Reading the first KB took between %d and %d cycles each", $time, minval, maxval);

		$stop();
	end
	
endmodule




// STRATEGIES


// FINDING BLOCKSIZE:
/*
Read 1 double word at a time. First time a piece of memory is blocksize*n)
*/


// FINDING BLOCKSIZE:
/*
Read from some number of block addresses (once you figure out blocksize), then reread from those block addresses.
The largest number of reads you can do where the second read is your hit rate is going to be your blocksize
*/


// FINDING associativity:
/*
Read again at addresses that would overlap with the first half of your blocks.
*/