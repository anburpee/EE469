`timescale 1ps/1ps
module cpu_pipelined (clk, reset);
    input logic clk, reset;

    // PC signals ----------------
    logic [63:0] pc_out, pc_plus4, shifter_out, br_adder_out, brAddr_mux_out, pc_mux_out1, pc_mux_out2, R_Rd; 
    // instructmem signals -------
    logic [31:0] instruction;
    // regfile signals -----------
    logic [4:0]  rd_addr2, wr_addr_reg;
    logic [63:0] rd_data1, rd_data2, wr_data_reg;
    logic comparator_zero;
    // ALU signals ---------------
    logic [63:0] alu_B, alu_result, datamem_out, wb_value, final_aluA, final_aluB;
    logic neg_flag, zero_flag, overflow_flag, cout_flag;
    // flagreg signals -----------
    logic [3:0]  flag_reg_out;
    // sign extension signals-----
    logic [63:0] condAddr19_extended, brAddr26_extended, imm12_extended, dAddr9_extended, extended_imm;
    // datamem signals -----------
    logic [63:0] mem_wrData;
    // mux sel signals -----------
    logic negative, overflow, neg_xor_overflow, cbz_and_zero, blt_and_lt; 
    logic pc_mux1_sel, rdAddr2_sel, fwd_alu_flag; 
    // control signals -----------
    logic Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
          SetFlags, isIType, Br2Reg, isBLT, isCBZ, IFFlush, RnUsed, RmUsed;
    logic [2:0] ALUOp; 
    // hazard detection ----------
    logic  IF_ID_write, PCWrite, FlushCntrl, LoadUseRn, LoadUseRm;
    // forwarding unit -----------
    logic [1:0] forwardA, forwardB, forwardStore, forwardR_Rd, forwardZero;

    // IF/ID signals ----------------
    logic [31:0] IF_ID_instruction;
    logic [63:0] IF_ID_pc, IF_ID_pc_plus4;
    logic IF_ID_reset;
    // ID/EX signals ----------------
    logic [63:0] ID_EX_readData1, ID_EX_readData2, ID_EX_extended_imm, ID_EX_pc_plus4;
    logic [4:0] ID_EX_Rn, ID_EX_Rm, ID_EX_Rd;
    logic [2:0] ID_EX_wb;  // {ID_EX_UncondBranch, ID_EX_MemtoReg, ID_EX_RegWrite}
    logic [1:0] ID_EX_mem; // {ID_EX_MemRead, ID_EX_MemWrite}
    logic [4:0] ID_EX_ex;  // {ID_EX_SetFlags, ID_EX_ALUSrc, ID_EX_ALUOp}
    logic [2:0] ID_EX_hds;  // {ID_EX_Br2Reg, ID_EX_RmUsed, ID_EX_RnUsed}
    logic [12:0] ID_EX_controls;
    // EX/MEM signals ----------------
    logic [63:0] EX_MEM_alu_result, EX_MEM_mem_wrData, EX_MEM_pc_plus4;
    logic [4:0] EX_MEM_Rd;
    logic [2:0] EX_MEM_wb;
    logic [1:0] EX_MEM_mem;
    logic EX_MEM_LoadUseRn, EX_MEM_LoadUseRm;
    // MEM/WB signals ---------------
    logic [63:0] MEM_WB_alu_result, MEM_WB_datamem_out, MEM_WB_pc_plus4;
    logic [4:0] MEM_WB_Rd;
    logic [2:0] MEM_WB_wb;
    logic MEM_WB_LoadUseRn, MEM_WB_LoadUseRm;


    // ----------------- Instruction Fetch (IF) -----------------------------------------------------------------
    instructmem instr_mem   (.address(pc_out), .instruction(instruction), .clk(clk));
    n_bit_register #(64) pc (.clk(clk), .reset(reset), .en(PCWrite), .data_in(pc_mux_out2), .data_out(pc_out)); 
    pc_adder pc_adder       (.A(pc_out), .sum(pc_plus4));
    // select signal for forwarding mux for neg/overflow -----
    and #(50) neg_ovfl_mux_sel (fwd_alu_flag, isBLT, ID_EX_ex[4]);
    // select signal for pc_mux1 -----------------------------
    and #(50) first_cond    (cbz_and_zero, isCBZ, zero);
    xor #(50) second_cond0  (neg_xor_overflow, negative, overflow);
    and #(50) second_cond   (blt_and_lt, isBLT, neg_xor_overflow);
    or #(50) pc_mux1sel     (pc_mux1_sel, UncondBranch, cbz_and_zero, blt_and_lt);
    // -------------------------------------------------------
    mux2_1 neg_mux    (.y(negative),  .x({neg_flag, flag_reg_out[3]}),      .sel(fwd_alu_flag));
    mux2_1 ovfl_mux   (.y(overflow),  .x({overflow_flag, flag_reg_out[1]}), .sel(fwd_alu_flag));
    muxnx2_1 #(64) pc_mux1 (.y(pc_mux_out1), .x({br_adder_out, pc_plus4}), .sel(pc_mux1_sel)); // PC+4 vs branch address
    muxnx2_1 #(64) pc_mux2 (.y(pc_mux_out2), .x({R_Rd, pc_mux_out1}),  .sel(Br2Reg)); // branch address vs BR address, output directly passed into PC

    muxnx4_1 #(1) zero_mux (.y(zero),  .x({1'd0, flag_reg_out[2], zero_flag, comparator_zero}),  .sel(forwardZero));
    muxnx4_1 #(64) R_Rd_mux (.y(R_Rd), .x({datamem_out, EX_MEM_alu_result, alu_result, rd_data2}),  .sel(forwardR_Rd));

    or #(50) reset_cond (IF_ID_reset, reset, IFFlush);
    IF_ID_reg IF_ID (.clk, .reset(IF_ID_reset), .wren(IF_ID_write), .instruction, .pc(pc_out), 
                     .pc_plus4, .IF_ID_instruction, .IF_ID_pc, .IF_ID_pc_plus4);

    
    // ------------------ Instruction Decode (ID) ---------------------------------------------------------------------------------
    sign_extender #(19, 64) sign_ex_condAddr19 (.x(IF_ID_instruction[23:5]), .y(condAddr19_extended)); // CB
    sign_extender #(26, 64) sign_ex_brAddr26   (.x(IF_ID_instruction[25:0]), .y(brAddr26_extended)); // B
    shifter shifter         (.value(brAddr_mux_out), .direction(1'd0), .distance(6'd2), .result(shifter_out)); // left shifts bytes address by 2
    muxnx2_1 #(64) brAddr_mux    (.y(brAddr_mux_out), .x({brAddr26_extended, condAddr19_extended}), .sel(UncondBranch)); // conditional branch address vs branch address
    branch_adder br_add     (.A(IF_ID_pc), .B(shifter_out), .sum(br_adder_out)); // computes PC=PC+(SignExtend(Imm)<<2)

    or #(50) rdAddr2sel     (rdAddr2_sel, Reg2Loc, isCBZ);
    muxnx2_1 #(5) rdAddr2_mux    (.y(rd_addr2),    .x({IF_ID_instruction[4:0], IF_ID_instruction[20:16]}), .sel(rdAddr2_sel));  // 5-bit 2:1 mux (0=Rm, 1=Rd) for rd_addr2 

    regfile reg_file (.ReadRegister1(IF_ID_instruction[9:5]), .ReadRegister2(rd_addr2), .WriteRegister(wr_addr_reg),
                      .WriteData(wr_data_reg), .RegWrite(MEM_WB_wb[0]), .clk(~clk), .ReadData1(rd_data1), .ReadData2(rd_data2));
    comparator64 zero_compare (.val(rd_data2), .comparator_zero);

    sign_extender #(9, 64) dAddr9 (.x(IF_ID_instruction[20:12]), .y(dAddr9_extended));
    zero_extender #(12, 64) imm12 (.x(IF_ID_instruction[21:10]), .y(imm12_extended));
    muxnx2_1 #(64) imm_mux (.y(extended_imm), .x({imm12_extended, dAddr9_extended}), .sel(isIType)); // mux (0=dAddr9_extended, 1=Imm12_extended) for ALU mux input

    muxnx2_1 #(13) hazard_mux (.y(ID_EX_controls), 
                               .x({13'b0, UncondBranch, MemtoReg, RegWrite, MemRead, MemWrite, SetFlags, ALUSrc, ALUOp[2:0], Br2Reg, RmUsed, RnUsed}), 
                               .sel(FlushCntrl));

    ID_EX_reg ID_EX (.clk, .reset, .wren(1'b1), .readData1(rd_data1), .readData2(rd_data2), .extended_imm, 
                     .IF_ID_Rn(IF_ID_instruction[9:5]), .IF_ID_Rm(IF_ID_instruction[20:16]), .IF_ID_Rd(IF_ID_instruction[4:0]), .IF_ID_pc_plus4,
                     .ID_EX_readData1, .ID_EX_readData2, .ID_EX_extended_imm, .ID_EX_Rn, .ID_EX_Rm, .ID_EX_Rd, .ID_EX_pc_plus4,
                     .wb(ID_EX_controls[12:10]), .mem(ID_EX_controls[9:8]), .ex(ID_EX_controls[7:3]),
                     .hds(ID_EX_controls[2:0]), .ID_EX_wb, .ID_EX_mem, .ID_EX_ex, .ID_EX_hds);
                     

    // ----------------- EXECUTION (EX) ---------------------------------------------------------------------------------------
    muxnx2_1 #(64) imm_vs_rdData2 (.y(alu_B),      .x({ID_EX_extended_imm, ID_EX_readData2}),                  .sel(ID_EX_ex[3]));
    muxnx4_1 #(64) forwardingA    (.y(final_aluA), .x({MEM_WB_pc_plus4, EX_MEM_alu_result, wb_value, ID_EX_readData1}),  .sel(forwardA));
    muxnx4_1 #(64) forwardingB    (.y(final_aluB), .x({MEM_WB_pc_plus4, EX_MEM_alu_result, wb_value, alu_B}),  .sel(forwardB));
    muxnx4_1 #(64) forwardingSTUR (.y(mem_wrData), .x({datamem_out, EX_MEM_alu_result, wb_value, ID_EX_readData2}), .sel(forwardStore));

    alu alu (.A(final_aluA), .B(final_aluB), .cntrl(ID_EX_ex[2:0]), .result(alu_result),
             .negative(neg_flag), .zero(zero_flag), .overflow(overflow_flag), .carry_out(cout_flag));

    n_bit_register #(4) flag_reg (.clk(clk), .reset(reset), .en(ID_EX_ex[4]), 
                                  .data_in({neg_flag, zero_flag, overflow_flag, cout_flag}), .data_out(flag_reg_out));

    EX_MEM_reg EX_MEM (.clk, .reset, .wren(1'b1), .alu_result, .alu_B(mem_wrData), .ID_EX_Rd, .ID_EX_wb, .ID_EX_mem, .LoadUseRn, .LoadUseRm, .ID_EX_pc_plus4,
                       .EX_MEM_alu_result, .EX_MEM_mem_wrData, .EX_MEM_Rd, .EX_MEM_wb, .EX_MEM_mem, .EX_MEM_LoadUseRn, .EX_MEM_LoadUseRm, .EX_MEM_pc_plus4);


    // ----------------- MEMORY ACCESS (MEM) ----------------------------------------------------------------------------------
    datamem datamem   (.address(EX_MEM_alu_result), .write_enable(EX_MEM_mem[0]), .read_enable(EX_MEM_mem[1]), .write_data(EX_MEM_mem_wrData),
                       .clk(clk), .xfer_size(4'd8), .read_data(datamem_out));

    MEM_WB_reg MEM_WB (.clk, .reset, .wren(1'b1), .EX_MEM_alu_result, .EX_MEM_Rd, .datamem_out, .EX_MEM_wb, .EX_MEM_LoadUseRn, .EX_MEM_LoadUseRm,
                       .EX_MEM_pc_plus4, .MEM_WB_alu_result, .MEM_WB_Rd, .MEM_WB_datamem_out, .MEM_WB_wb, .MEM_WB_LoadUseRn, .MEM_WB_LoadUseRm,
                       .MEM_WB_pc_plus4);


    // ----------------- WRITE BACK (WB) --------------------------------------------------------------------------------------
    muxnx2_1 #(64) alu_datamem_mux (.y(wb_value),    .x({MEM_WB_datamem_out, MEM_WB_alu_result}), .sel(MEM_WB_wb[1]));
    muxnx2_1 #(5)  rf_wrAddr_mux   (.y(wr_addr_reg), .x({5'd30, MEM_WB_Rd}),               .sel(MEM_WB_wb[2])); // 5-bit 2:1 mux (0=Rd, 1=5'd30) for wr_addr (5'd30 for BL)
    muxnx2_1 #(64) rf_wrData_mux   (.y(wr_data_reg), .x({MEM_WB_pc_plus4, wb_value}),                    .sel(MEM_WB_wb[2])); // 64-bit 2:1 mux (0=ALU/datamem output, 1=PC+4) for write data


    // ----------------- CONTROL ----------------------------------------------------------------------------------------------
    cpu_control control (.opcode(IF_ID_instruction[31:21]), .is_zero(comparator_zero), .is_lt(neg_xor_overflow), .Reg2Loc, .UncondBranch, .MemRead, .MemtoReg, 
                         .ALUOp, .MemWrite, .ALUSrc, .RegWrite, .SetFlags, .isIType, .Br2Reg, .isBLT, .isCBZ, .IFFlush, .RnUsed, .RmUsed);

    hazard_detection hazard_detect (.IF_ID_Rn(IF_ID_instruction[9:5]), .IF_ID_Rm(IF_ID_instruction[20:16]), .IF_ID_Rd(IF_ID_instruction[4:0]),
                                    .ID_EX_Rd, .ID_EX_MemRead(ID_EX_mem[1]), .RnUsed, .RmUsed, .Br2Reg, 
                                    .IF_ID_write, .PCWrite, .FlushCntrl, .LoadUseRn, .LoadUseRm);

    alu_forwarding alu_forwarding  (.isCBZ, .EX_MEM_RegWrite(EX_MEM_wb[0]), .MEM_WB_RegWrite(MEM_WB_wb[0]), .EX_MEM_Rd, .MEM_WB_Rd, .ID_EX_Rn, .ID_EX_Rm,
                                    .IF_ID_Rd(IF_ID_instruction[4:0]), .ID_EX_Rd, .ID_EX_MemWrite(ID_EX_mem[0]), .EX_MEM_MemWrite(EX_MEM_mem[0]), .EX_MEM_MemRead(EX_MEM_mem[1]),
                                    .ID_EX_RmUsed(ID_EX_hds[1]), .ID_EX_RnUsed(ID_EX_hds[0]), .MEM_WB_LoadUseRn, .MEM_WB_wb,
                                    .MEM_WB_LoadUseRm, .forwardA, .forwardB, .forwardStore, .forwardZero);
    BR_forwarding BR_forwarding    (.Br2Reg, .ID_EX_RegWrite(ID_EX_wb[0]), .EX_MEM_RegWrite(EX_MEM_wb[0]), .ID_EX_Br2Reg(ID_EX_hds[2]), .EX_MEM_MemRead(EX_MEM_mem[1]),
                                    .IF_ID_Rd(IF_ID_instruction[4:0]), .ID_EX_Rd, .EX_MEM_Rd, .forwardR_Rd);

endmodule



module cpu_pipelined_tb();
    logic clk, reset;
    logic [63:0] double_word;

    cpu_pipelined dut (.*);

    parameter CLOCK_PERIOD = 100000;

    // simulation clock
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    localparam NUM_INSTRUCTIONS = 300;
    // stimulus
    initial begin
        reset <= 1; repeat(10) @(posedge clk);
        reset <= 0;

        // -----------For debugging: look at contents after every clock cycle -------------

        $display("regfile contents: %p", dut.reg_file.reg_out); // regfile debug
        for (int i=0; i<NUM_INSTRUCTIONS; i++) begin
            $display("Timestamp: %t", $time);
            // $display("ID_EX_ex[4](SetFlags): %0d", dut.ID_EX_ex[4]);
            
            $display("IF/ID pc: %0d", dut.IF_ID_pc);
            $display("IF/ID instruction: %b", dut.IF_ID_instruction);
            // $display("MEM_WB_LoadUseRn: %0d, MEM_WB_LoadUseRm: %0d", dut.MEM_WB_LoadUseRn, dut.MEM_WB_LoadUseRm);

            
            // $display("pc_mux1_sel: %0d, blt_and_lt: %0d", dut.pc_mux1_sel, dut.blt_and_lt);
            
            // $display("ID_EX_MemWrite: %0d, ID_EX_Rd: %0d, EX_MEM_Rd: %0d, MEM_WB_Rd, %0d", 
            //          dut.ID_EX_mem[0], dut.ID_EX_Rd, dut.EX_MEM_Rd, dut.MEM_WB_Rd);
            // $display("datamem_out: %0d, EX_MEM_alu_result: %0d, wb_value: %0d, ID_EX_readData2: %0d, forwardStore: %0d",
            //          $signed(dut.datamem_out), $signed(dut.EX_MEM_alu_result), $signed(dut.wb_value), $signed(dut.ID_EX_readData2), dut.forwardStore);
            // $display("datamem_wrAddr: %0d, mem_wren: %0d, EX_MEM_mem_wrData: %0d", 
            //          dut.EX_MEM_alu_result, dut.EX_MEM_mem[0], $signed(dut.EX_MEM_mem_wrData));

            $display("ID_EX_Br2Reg: %d, ID_EX_Rd: %0d, EX_MEM_Rd: %0d, EX_MEM_MemRead, %0d", 
                     dut.ID_EX_hds[2], dut.ID_EX_Rd, dut.EX_MEM_Rd, dut.EX_MEM_mem[1]);
            $display("datamem_out: %0d, EX_MEM_alu_result: %0d, alu_result: %0d, rd_data2: %0d, sel: %0d",
                     dut.R_Rd_mux.x[255:192], dut.R_Rd_mux.x[191:128], dut.R_Rd_mux.x[127:64], dut.R_Rd_mux.x[63:0], 
                     dut.forwardR_Rd);
            $display("pc input: %0d, BR forwarding mux output: %0d", dut.pc.data_in, dut.R_Rd);
            
            $display("regfile contents:");
            foreach(dut.reg_file.reg_out[k]) begin // for each 64-bit register
                $write("%0d  ", $signed(dut.reg_file.reg_out[k])); // $write doesn't include \n at the end
            end
            $display("\n");
            $display("zero: %0d, negative: %0d, overflow: %0d", dut.zero, dut.negative, dut.overflow);
            $display("flag register contents:");
            $display("negative: %b, zero: %b, overflow: %b, carry-out: %d",
                    dut.flag_reg.data_out[3], dut.flag_reg.data_out[2], dut.flag_reg.data_out[1], dut.flag_reg.data_out[0]);

            // $display("datamem_wrAddr: %0d, mem_wren: %0d, EX_MEM_mem_wrData: %0d", 
            //          dut.EX_MEM_alu_result, dut.EX_MEM_mem[0], $signed(dut.EX_MEM_mem_wrData));
            // $display("datamem_out: %0d, EX_MEM_alu_result: %0d, wb_value: %0d, ID_EX_readData2: %0d, forwardStore: %0d",
            //          $signed(dut.datamem_out), $signed(dut.EX_MEM_alu_result), $signed(dut.wb_value), $signed(dut.ID_EX_readData2), $signed(dut.forwardStore));

            // $display("datamem contents:");
            // foreach(dut.datamem.mem[k]) begin;
            //     $write("%0d  ", $signed(dut.datamem.mem[k]));
            // end
            // $display("");

            $display("datamem contents:");
            // assume datamem is 128 bytes
            for (int j=128-8; j>=0; j-=8) begin
                double_word = {
                    dut.datamem.mem[j+7],
                    dut.datamem.mem[j+6],
                    dut.datamem.mem[j+5],
                    dut.datamem.mem[j+4],
                    dut.datamem.mem[j+3],
                    dut.datamem.mem[j+2],
                    dut.datamem.mem[j+1],
                    dut.datamem.mem[j]
                    
                };
                $write("%0d  ", $signed(double_word));
            end
            $display("");

            @(posedge clk);
        end
        $stop;

        // -----------Just look at the contents at the end---------------------------------
        // repeat(1000) @(posedge clk);
        // $display("instruction: %b", dut.instruction);
        // $display("regfile contents:");
        // foreach(dut.reg_file.reg_out[i]) begin // for each 64-bit register
        //     $write("%0d  ", $signed(dut.reg_file.reg_out[i])); // $write doesn't include \n at the end
        // end

        // $display("\nflag register contents:");
        // $display("negative: %b, zero: %b, overflow: %b, carry-out: %d",
        //         dut.flag_reg.data_in[3], dut.flag_reg.data_in[2], dut.flag_reg.data_in[1], dut.flag_reg.data_in[0]);

        // $display("datamem contents:");
        // foreach(dut.datamem.mem[i]) begin;
        //     $write("%0d  ", $signed(dut.datamem.mem[i]));
        // end

        // repeat(5) @(posedge clk);
        // $stop;
    end

endmodule