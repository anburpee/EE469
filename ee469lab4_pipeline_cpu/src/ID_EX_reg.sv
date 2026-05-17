module ID_EX_reg (clk, reset, wren, readData1, readData2, extended_imm, IF_ID_Rn, IF_ID_Rm, IF_ID_Rd, 
                  ID_EX_readData1, ID_EX_readData2, ID_EX_extended_imm, ID_EX_Rn, ID_EX_Rm, ID_EX_Rd,
                  IF_ID_wb, IF_ID_mem, IF_ID_ex, ID_EX_wb, ID_EX_mem, ID_EX_ex);

    input logic clk, reset, wren;
    input logic [63:0] readData1, readData2;
    input logic [63:0] extended_imm;
    input logic [63:0] IF_ID_Rn, IF_ID_Rm, IF_ID_Rd;
    // WB -------
    input logic IF_ID_wb;  // {UncondBranch, Mem2Reg, RegWrite}
    // MEM ------
    input logic IF_ID_mem; // {MemRead, MemWrite}
    // EX -------
    input logic IF_ID_ex;  // {SetFlags, ALUSrc, ALUOp}

    output logic [63:0] ID_EX_readData1, ID_EX_readData2;
    output logic [63:0] ID_EX_extended_imm;
    output logic [63:0] ID_EX_Rn, ID_EX_Rm, ID_EX_Rd;
    // WB -------
    output logic [2:0] ID_EX_wb;  // {ID_EX_UncondBranch, ID_EX_MemtoReg, ID_EX_RegWrite}
    // MEM ------
    output logic [1:0] ID_EX_mem; // {ID_EX_MemRead, ID_EX_MemWrite}
    // EX -------
    output logic [2:0] ID_EX_ex;  // { ID_EX_SetFlags, ID_EX_ALUSrc, ID_EX_ALUOp}

    assign ID_EX_wb = {ID_EX_UncondBranch, ID_EX_MemtoReg, ID_EX_RegWrite};
    assign ID_EX_mem = {ID_EX_MemRead, ID_EX_MemWrite};
    assign ID_EX_ex = {ID_EX_SetFlags, ID_EX_ALUSrc, ID_EX_ALUOp};

    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(readData1), .data_out(ID_EX_readData1));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(readData2), .data_out(ID_EX_readData2));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(extended_imm), .data_out(ID_EX_extended_imm));

    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rn), .data_out(ID_EX_Rn));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rm), .data_out(ID_EX_Rm));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_Rd), .data_out(ID_EX_Rd));

    n_bit_register #(3)  (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_wb), .data_out(ID_EX_wb));
    n_bit_register #(2)  (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_mem), .data_out(ID_EX_mem));
    n_bit_register #(3)  (.clk(clk), .reset(reset), .en(wren), .data_in(IF_ID_ex), .data_out(ID_EX_ex));

endmodule