module EX_MEM_reg (clk, reset, wren, alu_result, alu_b, ID_EX_Rd, ID_EX_wb, ID_EX_mem,  
                   EX_MEM_alu_result, EX_MEM_alu_b, EX_MEM_Rd, EX_MEM_wb, EX_MEM_mem);
    
    input logic clk, reset, wren;
    input logic [63:0] alu_result, alu_b;
    input logic [63:0] ID_EX_Rd;
    input logic [63:0] ID_EX_wb, ID_EX_mem;

    output logic [63:0] EX_MEM_alu_result, EX_MEM_alu_b;
    output logic [63:0] EX_MEM_Rd;
    output logic [2:0] EX_MEM_wb;
    output logic [1:0] EX_MEM_mem;

    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(alu_result), .data_out(EX_MEM_alu_result));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(alu_b), .data_out(EX_MEM_alu_b));
    n_bit_register #(64) (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_Rd), .data_out(EX_MEM_Rb));
    n_bit_register #(3)  (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_wb), .data_out(EX_MEM_wb));
    n_bit_register #(2)  (.clk(clk), .reset(reset), .en(wren), .data_in(ID_EX_wb), .data_out(EX_MEM_mem));

endmodule