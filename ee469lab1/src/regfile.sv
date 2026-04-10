// 32x64 register file
// readRegister = rd_addr
// writeRegister = wr_addr
`timescale 1ns/10ps
module regfile(ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, ReadData1, ReadData2);

    input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    input logic [63:0] WriteData;
    input logic RegWrite, clk; // reset optional
    output logic [63:0] ReadData1, ReadData2;
    
    logic reset;

    logic [31:0] dec_out; // output to 5:32 decoder

    //[rows-1:0][cols-1:0] 
    logic [31:0][63:0] reg_out; // only need 31 outputs because the 32nd register is just zeros
    
    assign reset = 1'b0;

    // 5:32 decoder (in charge of writing operations)
    decoder5_32 dec5_32 (.y(dec_out), .x(WriteRegister), .en(RegWrite));

    // generate 31 (not 32) instances of 64-bit registers (b/c register 31 is hardwired to 0.)
    genvar i, j;
    generate       
        for (i=0; i<31; i++) begin: reg_block
            register64 reg64 (.data_out(reg_out[i]), .data_in(WriteData), .wren(dec_out[i]), .reset(reset), .clk(clk));
        end
    endgenerate
    
    // register 31 is all zeroes
    assign reg_out[31] = 64'd0;

    // 64x(32:1) mux for reading from register
    mux64_32_1 big_boy1 (.y(ReadData1), .x(reg_out), .sel(ReadRegister1));
    mux64_32_1 big_boy2 (.y(ReadData2), .x(reg_out), .sel(ReadRegister2));
    
endmodule // regfile


module regfile_tb();

    logic  [4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, reset, clk;
	logic [63:0]	ReadData1, ReadData2;

    // dut
    regfile dut (.*);
    
    // simulation clock
    parameter CLOCK_PERIOD = 5000;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    // stimulus
    integer i;
    initial begin
        @(posedge clk);

        reset <= 1; @(posedge clk);
        reset <= 0; 

        // write enable on
        // should read off initial values since write data hasn't reached the registers yet (registers are currently being written to)
        RegWrite <= 1;
        for (i=0; i<32; i++) begin
            WriteRegister <= i;
            WriteData <= i*10;
            ReadRegister1 <= i;  
            ReadRegister2 <= i - 1;
            @(posedge clk);
        end

        // write enable off
        RegWrite <= 0;
        for (i=0; i<32; i++) begin
            WriteRegister <= i;
            WriteData <= i*100;
            ReadRegister1 <= i;  // contents should be updated to addr*10
            ReadRegister2 <= i - 1;
            @(posedge clk);
        end

         // write enable off
        for (i=0; i<32; i++) begin
            ReadRegister1 <= i;  // contents should NOT be updated to addr*100 (still should read addr*10)
            ReadRegister2 <= i - 1;
            @(posedge clk);
        end
        
        $stop;
    end

endmodule // regfile_tb