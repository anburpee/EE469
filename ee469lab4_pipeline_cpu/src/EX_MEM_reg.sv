module EX_MEM_reg (clk, reset, wren, alu_result, alu_B, ID_EX_Rd, ID_EX_wb, ID_EX_mem, LoadUseRn, LoadUseRm,  
                   EX_MEM_alu_result, EX_MEM_mem_wrData, EX_MEM_Rd, EX_MEM_wb, EX_MEM_mem, EX_MEM_LoadUseRn, EX_MEM_LoadUseRm);
    
    input logic clk, reset, wren;
    input logic [63:0] alu_result, alu_B;
    input logic [4:0] ID_EX_Rd;
    input logic [63:0] ID_EX_wb, ID_EX_mem;
    input logic LoadUseRn, LoadUseRm;

    output logic [63:0] EX_MEM_alu_result, EX_MEM_mem_wrData;
    output logic [4:0] EX_MEM_Rd;
    output logic [2:0] EX_MEM_wb;
    output logic [1:0] EX_MEM_mem;
    output logic EX_MEM_LoadUseRn, EX_MEM_LoadUseRm;

    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(alu_result), .data_out(EX_MEM_alu_result));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(alu_B), .data_out(EX_MEM_mem_wrData));
    n_bit_register #(5)  (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_Rd), .data_out(EX_MEM_Rd));
    n_bit_register #(3)  (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_wb), .data_out(EX_MEM_wb));
    n_bit_register #(2)  (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_mem), .data_out(EX_MEM_mem));
    n_bit_register #(1)  (.clk(clk), .reset(reset), .en(wren), .data_in(LoadUseRn), .data_out(EX_MEM_LoadUseRn));
    n_bit_register #(1)  (.clk(clk), .reset(reset), .en(wren), .data_in(LoadUseRm), .data_out(EX_MEM_LoadUseRm));

endmodule