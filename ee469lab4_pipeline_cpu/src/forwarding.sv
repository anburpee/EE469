// Forwarding unit for write-use hazards, load-use hazards, load-store hazards, write-store hazards, and write-CBZ hazards
module alu_forwarding (isCBZ, EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rn, ID_EX_Rm, ID_EX_RnUsed, ID_EX_RmUsed,
                       MEM_WB_LoadUseRn, MEM_WB_LoadUseRm, IF_ID_Rd, ID_EX_Rd, ID_EX_MemWrite, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_WB_wb,
                       forwardA, forwardB, forwardStore, forwardZero);

input logic isCBZ, EX_MEM_RegWrite, MEM_WB_RegWrite, ID_EX_RnUsed, ID_EX_RmUsed, MEM_WB_LoadUseRn, MEM_WB_LoadUseRm;
input logic ID_EX_MemWrite, EX_MEM_MemWrite, EX_MEM_MemRead;
input logic [4:0] EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rn, ID_EX_Rm;
input logic [4:0] IF_ID_Rd, ID_EX_Rd;
input logic [2:0] MEM_WB_wb; // MEM_WB_wb[2] = MEM_WB_UncondBranch, MEM_WB_wb[0] = MEM_WB_RegWrite

// 00 = default (no forwarding)
// 01 = MEM/WB forwarding
// 10 = EX/MEM forwarding
output logic [1:0] forwardA, forwardB;

// 00 = default (no forwarding)
// 01 = MEM/WB forwarding
// 10 = EX/MEM forwarding -- ALU output
// 11 = EX/MEM forwarding -- datamem output
output logic [1:0] forwardStore; // for write-cbz

// 00 = default (comparator zero)
// 01 = alu zero flag wire
// 10 = flag register zero
output logic [1:0] forwardZero;

logic BL_in_WB;
assign BL_in_WB = MEM_WB_wb[2] && MEM_WB_wb[0];

always_comb begin
    forwardA = 2'b00;
    forwardB = 2'b00;
    forwardStore = 2'b00;
    forwardZero = 2'b00;

    if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd31)) begin
        if ((ID_EX_Rn == EX_MEM_Rd) && ID_EX_RnUsed) begin
            forwardA = 2'b10;
        end
        if ((ID_EX_Rm == EX_MEM_Rd) && ID_EX_RmUsed) begin
            forwardB = 2'b10;
        end
    end
    // does not execute if EX/MEM forwarding (for edge case of two back-to-back EX/MEM forwarding)
    if ((MEM_WB_RegWrite && (MEM_WB_Rd != 5'd31))) begin // BL instruction in mem/wb stage
        if ((ID_EX_Rn == MEM_WB_Rd) && ID_EX_RnUsed &&
            !((EX_MEM_RegWrite) && (EX_MEM_Rd != 5'd31) && ((ID_EX_Rn == EX_MEM_Rd)))) begin 
            forwardA = 2'b01;
        end
        if ((ID_EX_Rm == MEM_WB_Rd) && ID_EX_RmUsed &&
            !(EX_MEM_RegWrite && (EX_MEM_Rd != 5'd31) && ((ID_EX_Rm == EX_MEM_Rd)))) begin
            forwardB = 2'b01;
        end
    end

    // for write use hazard for BL specifically (BL, then read from X30)
    if (BL_in_WB) begin
        if ((ID_EX_Rn == 30) && ID_EX_RnUsed) begin 
            forwardA = 2'b11;
        end
        if ((ID_EX_Rm == 30) && ID_EX_RmUsed) begin 
            forwardB = 2'b11;
        end
    end

    // for load-use hazards
    if (MEM_WB_LoadUseRn) begin
        forwardA = 2'b01;
    end
    if (MEM_WB_LoadUseRm) begin
        forwardB = 2'b01;
    end

    // for write-store/load-store hazards
    if (ID_EX_MemWrite && (ID_EX_Rd != 5'd31)) begin // ID/EX has store instruction
        if ((ID_EX_Rd == EX_MEM_Rd) && (!EX_MEM_MemWrite)) begin
            if (EX_MEM_MemRead) begin // load-store
                forwardStore = 2'b11;
            end
            else if (EX_MEM_RegWrite) begin // use-store
                forwardStore = 2'b10;
            end
        end
        else if ((MEM_WB_RegWrite) && (ID_EX_Rd == MEM_WB_Rd)) begin
            forwardStore = 2'b01;
        end
    end


    // for write-CBZ hazards
    if (isCBZ && (ID_EX_Rd != 5'd31)) begin
        if (ID_EX_Rd == IF_ID_Rd) begin
            forwardZero = 2'b01;
        end
        else if (EX_MEM_Rd == IF_ID_Rd) begin
            forwardZero = 2'b10;
        end
    end



end
endmodule


// Forwarding unit for write-BR hazards and load-BR hazards
module BR_forwarding (Br2Reg, ID_EX_RegWrite, EX_MEM_RegWrite, ID_EX_Br2Reg, EX_MEM_MemRead, IF_ID_Rd, ID_EX_Rd, EX_MEM_Rd, forwardR_Rd);

input logic Br2Reg, ID_EX_RegWrite, EX_MEM_RegWrite, ID_EX_Br2Reg, EX_MEM_MemRead;
input logic [4:0] IF_ID_Rd, ID_EX_Rd, EX_MEM_Rd;

// 00 = default (no forwarding)
// 01 = EX forwarding (raw alu result) 
// 10 = MEM forwarding (EX_MEM_alu_result) 
// 11 = MEM forwarding (datamem readData) --- for load-BR hazard
output logic [1:0] forwardR_Rd;


always_comb begin
    forwardR_Rd = 2'b00;

    if (Br2Reg && (IF_ID_Rd != 5'd31)) begin
        if (ID_EX_RegWrite && (IF_ID_Rd == ID_EX_Rd)) begin // write-BR --EX
            forwardR_Rd = 2'b01;
        end
        else if (EX_MEM_MemRead && ((IF_ID_Rd == EX_MEM_Rd))) begin // load-BR -- (LDUR, NOOP, BR)
            forwardR_Rd = 2'b11;
        end
        else if (EX_MEM_RegWrite && (IF_ID_Rd == EX_MEM_Rd)) begin // write-BR --MEM
            forwardR_Rd = 2'b10;
        end
    end
    else if (ID_EX_Br2Reg && EX_MEM_MemRead && (ID_EX_Rd != 5'd31) && (ID_EX_Rd == EX_MEM_Rd)) begin // (LUDR, BR)
        forwardR_Rd = 2'b11;
    end
end
endmodule