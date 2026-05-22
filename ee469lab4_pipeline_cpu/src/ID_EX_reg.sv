`timescale 1ps/1ps
module ID_EX_reg (clk, reset, wren, readData1, readData2, extended_imm, IF_ID_Rn, IF_ID_Rm, IF_ID_Rd, IF_ID_pc_plus4,
                  ID_EX_readData1, ID_EX_readData2, ID_EX_extended_imm, ID_EX_Rn, ID_EX_Rm, ID_EX_Rd, ID_EX_pc_plus4,
                  wb, mem, ex, hds, ID_EX_wb, ID_EX_mem, ID_EX_ex, ID_EX_hds);

    input logic clk, reset, wren;
    input logic [63:0] readData1, readData2;
    input logic [63:0] extended_imm;
    input logic [63:0] IF_ID_pc_plus4;
    input logic [4:0] IF_ID_Rn, IF_ID_Rm, IF_ID_Rd;
    // WB -------
    input logic [2:0] wb;  // {UncondBranch, Mem2Reg, RegWrite}
    // MEM ------
    input logic [1:0] mem; // {MemRead, MemWrite}
    // EX -------
    input logic [4:0] ex;  // {SetFlags, ALUSrc, ALUOp}
    // HDS -------
    input logic [1:0] hds;  // {RmUsed, RnUsed}

    output logic [63:0] ID_EX_readData1, ID_EX_readData2;
    output logic [63:0] ID_EX_extended_imm;
    output logic [63:0] ID_EX_pc_plus4;
    output logic [4:0] ID_EX_Rn, ID_EX_Rm, ID_EX_Rd;
    // WB -------
    output logic [2:0] ID_EX_wb;  // {ID_EX_UncondBranch, ID_EX_MemtoReg, ID_EX_RegWrite}
    // MEM ------
    output logic [1:0] ID_EX_mem; // {ID_EX_MemRead, ID_EX_MemWrite}
    // EX -------
    output logic [4:0] ID_EX_ex;  // {ID_EX_SetFlags, ID_EX_ALUSrc, ID_EX_ALUOp}
    // Hazard Detection Signals -------
    output logic [1:0] ID_EX_hds;  // {ID_EX_RmUsed, ID_EX_RnUsed}


    n_bit_register #(64) reg0 (.clk(clk), .reset(reset), .en(wren), .data_in(readData1), .data_out(ID_EX_readData1));
    n_bit_register #(64) reg1 (.clk(clk), .reset(reset), .en(wren), .data_in(readData2), .data_out(ID_EX_readData2));
    n_bit_register #(64) reg2 (.clk(clk), .reset(reset), .en(wren), .data_in(extended_imm), .data_out(ID_EX_extended_imm));

    n_bit_register #(5)  reg3 (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rn), .data_out(ID_EX_Rn));
    n_bit_register #(5)  reg4 (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rm), .data_out(ID_EX_Rm));
    n_bit_register #(5)  reg5 (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rd), .data_out(ID_EX_Rd));

    n_bit_register #(3)  reg6 (.clk(clk), .reset(reset), .en(wren), .data_in(wb), .data_out(ID_EX_wb));
    n_bit_register #(2)  reg7 (.clk(clk), .reset(reset), .en(wren), .data_in(mem), .data_out(ID_EX_mem));
    n_bit_register #(5)  reg8 (.clk(clk), .reset(reset), .en(wren), .data_in(ex), .data_out(ID_EX_ex));
    n_bit_register #(2)  reg9 (.clk(clk), .reset(reset), .en(wren), .data_in(hds), .data_out(ID_EX_hds));

    n_bit_register #(64) reg10 (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_pc_plus4), .data_out(ID_EX_pc_plus4));

endmodule