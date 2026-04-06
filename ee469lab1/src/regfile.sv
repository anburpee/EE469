// 32x64 register file
// readRegister = rd_addr
// writeRegister = wr_addr
`timescale 1ns/10ps
module regfile(ReadData1, ReadData2, ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, reset, clk);
    
    output logic [63:0] ReadData1, ReadData2;
    input logic [63:0] WriteData;
    input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    input logic RegWrite, reset, clk; // NO RESET??
    logic [31:0] dec_out;
    logic [63:0] reg_out [31:0];

    // 5:32 decoder (in charge of writing operations)
    decoder5_32 dec5_32 (.y(dec_out), .x(WriteRegister), .en(RegWrite));

    // generate 31 (not 32) instances of 64-bit registers (b/c register 31 is hardwired to 0.)
    genvar i, j;
    generate       
        for (i=0; i<31; i++) begin: reg_block
            register64 reg64 (.data_out(reg_out[i]), .data_in(WriteData), .wren(dec_out[i]), .reset(reset), .clk(clk));
        end
    endgenerate

    // 64x(32:1) multiplexors (in charge of reading operations)
    generate 
        for (j=0; j<64; j++) begin: mux_block     // all regs, at bit j
            mux32_1 mux32a (.y(ReadData1[j]), .x({1'b0,
                                                  reg_out[30][j],
                                                  reg_out[29][j],
                                                  reg_out[28][j],
                                                  reg_out[27][j],
                                                  reg_out[26][j],
                                                  reg_out[25][j],
                                                  reg_out[24][j],
                                                  reg_out[23][j],
                                                  reg_out[22][j],
                                                  reg_out[21][j],
                                                  reg_out[20][j],
                                                  reg_out[19][j],
                                                  reg_out[18][j],
                                                  reg_out[17][j],
                                                  reg_out[16][j],
                                                  reg_out[15][j],
                                                  reg_out[14][j],
                                                  reg_out[13][j],
                                                  reg_out[12][j],
                                                  reg_out[11][j],
                                                  reg_out[10][j],
                                                  reg_out[9][j],
                                                  reg_out[8][j],
                                                  reg_out[7][j],
                                                  reg_out[6][j],
                                                  reg_out[5][j],
                                                  reg_out[4][j],
                                                  reg_out[3][j],
                                                  reg_out[2][j],
                                                  reg_out[1][j],
                                                  reg_out[0][j]}), .sel(ReadRegister1));

            mux32_1 mux32b (.y(ReadData2[j]), .x({1'b0,
                                                  reg_out[30][j],
                                                  reg_out[29][j],
                                                  reg_out[28][j],
                                                  reg_out[27][j],
                                                  reg_out[26][j],
                                                  reg_out[25][j],
                                                  reg_out[24][j],
                                                  reg_out[23][j],
                                                  reg_out[22][j],
                                                  reg_out[21][j],
                                                  reg_out[20][j],
                                                  reg_out[19][j],
                                                  reg_out[18][j],
                                                  reg_out[17][j],
                                                  reg_out[16][j],
                                                  reg_out[15][j],
                                                  reg_out[14][j],
                                                  reg_out[13][j],
                                                  reg_out[12][j],
                                                  reg_out[11][j],
                                                  reg_out[10][j],
                                                  reg_out[9][j],
                                                  reg_out[8][j],
                                                  reg_out[7][j],
                                                  reg_out[6][j],
                                                  reg_out[5][j],
                                                  reg_out[4][j],
                                                  reg_out[3][j],
                                                  reg_out[2][j],
                                                  reg_out[1][j],
                                                  reg_out[0][j]}), .sel(ReadRegister2));
        end
    endgenerate

endmodule // regfile


module regfile_tb();

    logic [63:0] ReadData1, ReadData2;
    logic [63:0] WriteData;
    logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    logic RegWrite, reset, clk;

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








// generate 32 instances of 64-bit registers
    // genvar i;
    // generate
    //              // 32-1 because 31st register is assigned to all zeros
    //     for (i=0; i<32-1; i++) begin: reg_block // registers 0-30 
    //         register64 reg64 (.data_out(reg_out[i]), .data_in(WriteData), .RegWrite(dec_out[i]), .reset(reset), .clk(clk));
    //     end
    // endgenerate

    // 31st register                                                // high impedence
    // register64 reg64_31 (.data_out(reg_out[i]), .data_in(64'd0), .RegWrite(1'bZ), .reset(reset), .clk(clk));