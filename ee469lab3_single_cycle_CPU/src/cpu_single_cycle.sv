`timescale 1ps/1ps
module cpu_single_cycle (clk, reset);
    input logic clk, reset;

    // PC signals ----------------
    logic [63:0] pc_out, pc_plus4, shifter_out, br_adder_out, brAddr_mux_out, pc_mux_out1, pc_mux_out2; 

    // instructmem signals -------
    logic [31:0] instruction;

    // regfile signals -----------
    logic [4:0]  rd_addr2, wr_addr_reg;
    logic [63:0] rd_data1, rd_data2, wr_data_reg;

    // ALU signals ---------------
    logic [63:0] alu_B, alu_out, datamem_out, alu_datamem_mux_out;
    logic neg_flag, zero_flag, overflow_flag, cout_flag;

    // flagreg signals -----------
    logic [3:0]  flag_reg_out;

    // sign extension signals-----
    logic [63:0] condAddr19_extended, brAddr26_extended, imm12_extended, dAddr9_extended, extended_imm;

    // mux sel signals -----------
    logic neg_xor_overflow, cbz_and_zero, not_cbz, blt_and_lt, pc_mux1_sel; // mux select for pc_mux1
    logic rdAddr2_sel; // mux select for regfile rdAddr2 

    // control signals -----------
    logic Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, SetFlags, IType, Br2Reg, isBLT, isCBZ;
    logic [2:0] ALUOp; 


    // ----------------- PROGRAM COUNTER -----------------------------------------------------------------
    n_bit_register #(64) pc (.clk(clk), .reset(reset), .en(1'b1), .data_in(pc_mux_out2), .data_out(pc_out)); // program counter
    
    pc_adder pc_add (.A(pc_out), .sum(pc_plus4)); // dedicated adder to for PC + 4

    shifter shifter (.value(brAddr_mux_out), .direction(1'd0), .distance(6'd2), .result(shifter_out)); // left shifts bytes address by 2 
    
    branch_adder br_add (.A(pc_out), .B(shifter_out), .sum(br_adder_out)); // computes PC=PC+(SignExtend(Imm)<<2)

    // select signal for pc_mux1 -----------
    and #(50) first_cond (cbz_and_zero, isCBZ, zero_flag);
    xor #(50) second_cond0 (neg_xor_overflow, flag_reg_out[3], flag_reg_out[1]);
    and #(50) second_cond (blt_and_lt, isBLT, neg_xor_overflow);
    or #(50) pc_mux1sel (pc_mux1_sel, UncondBranch, cbz_and_zero, blt_and_lt);
    // -------------------------------------

    mux64x2_1 pc_mux1 (.y(pc_mux_out1), .x({br_adder_out, pc_plus4}), .sel(pc_mux1_sel)); // PC+4 vs branch address
    mux64x2_1 pc_mux2 (.y(pc_mux_out2), .x({rd_data2, pc_mux_out1}), .sel(Br2Reg)); // branch address vs BR address, output directly passed into PC
    mux64x2_1 brAddr_mux (.y(brAddr_mux_out), .x({brAddr26_extended, condAddr19_extended}), .sel(UncondBranch)); // conditional branch address vs branch address

    sign_extender #(19, 64) sign_ex_condAddr19 (.x(instruction[23:5]), .y(condAddr19_extended)); // CB
    sign_extender #(26, 64) sign_ex_brAddr26 (.x(instruction[25:0]), .y(brAddr26_extended)); // B
    // ----------------------------------------------------------------------------------------------------


    instructmem instr_mem (.address(pc_out), .instruction(instruction), .clk(clk));


    // ----------------- REGISTER FILE --------------------------------------------------------------------
    or #(50) rdAddr2sel (rdAddr2_sel, Reg2Loc, isCBZ);
    mux5x2_1 rdAddr2_mux (.y(rd_addr2), .x({instruction[4:0], instruction[20:16]}), .sel(rdAddr2_sel)); // 5-bit 2:1 mux (0=Rm, 1=Rd) for rd_addr2 
    mux5x2_1 wrAddr_mux (.y(wr_addr_reg), .x({5'd30, instruction[4:0]}), .sel(UncondBranch)); // 5-bit 2:1 mux (0=Rd, 1=5'd30) for wr_addr (5'd30 for BL)
    mux64x2_1 wrData_mux (.y(wr_data_reg), .x({pc_plus4, alu_datamem_mux_out}), .sel(UncondBranch)); // 64-bit 2:1 mux (0=ALU/datamem output, 1=PC+4) for write data

    regfile reg_file (.ReadRegister1(instruction[9:5]), .ReadRegister2(rd_addr2), .WriteRegister(wr_addr_reg),
                      .WriteData(wr_data_reg), .RegWrite(RegWrite), .clk(clk), .ReadData1(rd_data1), .ReadData2(rd_data2));
    // ----------------------------------------------------------------------------------------------------


    sign_extender #(9, 64) dAddr9 (.x(instruction[20:12]), .y(dAddr9_extended));
    zero_extender #(12, 64) imm12 (.x(instruction[21:10]), .y(imm12_extended));


    // ----------------- ALU ------------------------------------------------------------------------------
    mux64x2_1 imm_mux (.y(extended_imm), .x({imm12_extended, dAddr9_extended}), .sel(IType)); // mux (0=dAddr9_extended, 1=Imm12_extended) for ALU mux input
    mux64x2_1 alu_mux (.y(alu_B), .x({extended_imm, rd_data2}), .sel(ALUSrc)); // mux (1=exteded(imm), 0=ReadData2) for B-port of the ALU

    alu alu (.A(rd_data1), .B(alu_B), .cntrl(ALUOp), .result(alu_out),
             .negative(neg_flag), .zero(zero_flag), .overflow(overflow_flag), .carry_out(cout_flag));

    // flag register: flag_reg[3] = negative, flag_reg[2] = zero, flag_reg[1] = overflow, flagreg[0] = carry-out
    n_bit_register #(4) flag_reg (.clk(clk), .reset(reset), .en(SetFlags), 
                                       .data_in({neg_flag, zero_flag, overflow_flag, cout_flag}), .data_out(flag_reg_out));
    // ----------------------------------------------------------------------------------------------------

    //                                                                          1'b1 should also be fine
    datamem datamem (.address(alu_out), .write_enable(MemWrite), .read_enable(MemtoReg), .write_data(rd_data2),
                     .clk(clk), .xfer_size(4'd8), .read_data(datamem_out));


    // mux to pick whether ALU output or memory output gets written to the regfile
    mux64x2_1 alu_datamem_mux (.y(alu_datamem_mux_out), .x({datamem_out, alu_out}), .sel(MemtoReg));


    cpu_control control (.opcode(instruction[31:21]), .Reg2Loc, .UncondBranch, .MemRead, .MemtoReg, 
                         .ALUOp, .MemWrite, .ALUSrc, .RegWrite, .SetFlags, .IType, .Br2Reg, .isBLT, .isCBZ);

endmodule



module cpu_single_cycle_tb();
    logic clk, reset;

    cpu_single_cycle dut (.*);

    parameter CLOCK_PERIOD = 100000;

    // simulation clock
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    // localparam NUM_INSTRUCTIONS = 500;
    // stimulus
    integer i;
    initial begin
        reset <= 1; @(posedge clk);
        reset <= 0;

        // -----------For debugging: look at contents after every clock cycle -------------
        // $display("regfile contents: %p", dut.reg_file.reg_out); // regfile debug
        // for (i=0; i<NUM_INSTRUCTIONS; i++) begin
        //     $display("instruction: %b", dut.instruction);
        //     $display("regfile contents:");
        //     foreach(dut.reg_file.reg_out[i]) begin // for each 64-bit register
        //         $write("%0d  ", $signed(dut.reg_file.reg_out[i])); // $write doesn't include \n at the end
        //     end

        //     $display("\nflag register contents:");
        //     $display("negative: %b, zero: %b, overflow: %b, carry-out: %d",
        //             dut.flag_reg.data_in[3], dut.flag_reg.data_in[2], dut.flag_reg.data_in[1], dut.flag_reg.data_in[0]);

        //     $display("datamem contents:");
        //     foreach(dut.datamem.mem[i]) begin;
        //         $write("%0d  ", $signed(dut.datamem.mem[i]));
        //     end
        //     $display("");
        //     @(posedge clk);
        // end

        // -----------Just look at the contents at the end---------------------------------
        repeat(1000) @(posedge clk);
        $display("instruction: %b", dut.instruction);
        $display("regfile contents:");
        foreach(dut.reg_file.reg_out[i]) begin // for each 64-bit register
            $write("%0d  ", $signed(dut.reg_file.reg_out[i])); // $write doesn't include \n at the end
        end

        $display("\nflag register contents:");
        $display("negative: %b, zero: %b, overflow: %b, carry-out: %d",
                dut.flag_reg.data_in[3], dut.flag_reg.data_in[2], dut.flag_reg.data_in[1], dut.flag_reg.data_in[0]);

        $display("datamem contents:");
        foreach(dut.datamem.mem[i]) begin;
            $write("%0d  ", $signed(dut.datamem.mem[i]));
        end

        repeat(5) @(posedge clk);
        $stop;
    end

endmodule