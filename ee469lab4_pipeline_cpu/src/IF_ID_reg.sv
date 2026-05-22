`timescale 1ps/1ps
module IF_ID_reg (clk, reset, wren, instruction, pc, pc_plus4, IF_ID_instruction, IF_ID_pc, IF_ID_pc_plus4);

    input logic clk, reset, wren;
    input logic [31:0] instruction;
    input logic [63:0] pc, pc_plus4;

    output logic [31:0] IF_ID_instruction;
    output logic [63:0] IF_ID_pc, IF_ID_pc_plus4;

    n_bit_register #(32) reg0 (.clk(clk), .reset(reset), .en(wren), .data_in(instruction), .data_out(IF_ID_instruction));
    n_bit_register #(64) reg1 (.clk(clk), .reset(reset), .en(wren), .data_in(pc), .data_out(IF_ID_pc));
    n_bit_register #(64) reg2 (.clk(clk), .reset(reset), .en(wren), .data_in(pc_plus4), .data_out(IF_ID_pc_plus4));

endmodule