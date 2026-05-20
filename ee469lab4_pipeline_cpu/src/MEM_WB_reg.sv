module MEM_WB_reg (clk, reset, wren, EX_MEM_alu_result, EX_MEM_Rd, datamem_out, EX_MEM_wb, EX_MEM_LoadUseRn, EX_MEM_LoadUseRm,
                   MEM_WB_alu_result, MEM_WB_Rd, MEM_WB_datamem_out, MEM_WB_wb, MEM_WB_LoadUseRn, MEM_WB_LoadUseRm);
    
    input logic clk, reset, wren;
    input logic [63:0] EX_MEM_alu_result;
    input logic [4:0] EX_MEM_Rd;
    input logic [63:0] datamem_out;
    input logic [2:0] EX_MEM_wb;
    input logic EX_MEM_LoadUseRn, EX_MEM_LoadUseRm;

    output logic [63:0] MEM_WB_alu_result;
    output logic [4:0] MEM_WB_Rd;
    output logic [63:0] MEM_WB_datamem_out;
    output logic [2:0] MEM_WB_wb;
    output logic MEM_WB_LoadUseRn, MEM_WB_LoadUseRm;

    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(EX_MEM_alu_result), .data_out(MEM_WB_alu_result));
    n_bit_register #(5)  (.clk(clk), .reset(reset), .en(wren), .data_in(EX_MEM_Rd), .data_out(MEM_WB_Rd));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(datamem_out), .data_out(MEM_WB_datamem_out));
    n_bit_register #(3)  (.clk(clk), .reset(reset), .en(wren), .data_in(EX_MEM_wb), .data_out(MEM_WB_wb));
    n_bit_register #(1)  (.clk(clk), .reset(reset), .en(wren), .data_in(EX_MEM_LoadUseRn), .data_out(MEM_WB_LoadUseRn));
    n_bit_register #(1)  (.clk(clk), .reset(reset), .en(wren), .data_in(EX_MEM_LoadUseRm), .data_out(MEM_WB_LoadUseRm));

endmodule