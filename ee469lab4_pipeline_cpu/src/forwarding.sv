// Forwarding unit for write-use hazards, load-use hazards, and write-store hazards
module alu_forwarding (EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rn, ID_EX_Rm, ID_EX_RnUsed, ID_EX_RmUsed,
                       MEM_WB_LoadUseRn, MEM_WB_LoadUseRm, ID_EX_Rd, ID_EX_MemWrite, EX_MEM_MemRead,
                       forwardA, forwardB, forwardStore);

input logic EX_MEM_RegWrite, MEM_WB_RegWrite, ID_EX_RnUsed, ID_EX_RmUsed, MEM_WB_LoadUseRn, MEM_WB_LoadUseRm;
input logic ID_EX_MemWrite, EX_MEM_MemRead;
input logic [4:0] EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rn, ID_EX_Rm;
input logic [4:0] ID_EX_Rd;

// 00 = default (no forwarding)
// 01 = MEM/WB forwarding
// 10 = EX/MEM forwarding
output logic [1:0] forwardA, forwardB;

// 00 = default (no forwarding)
// 01 = MEM/WB forwarding
// 10 = EX/MEM forwarding -- ALU output
// 11 = EX/MEM forwarding -- datamem output
output logic [1:0] forwardStore;


always_comb begin
    forwardA = 2'b00;
    forwardB = 2'b00;
    forwardStore = 2'b00;

    if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd31)) begin
        if ((ID_EX_Rn == EX_MEM_Rd) && ID_EX_RnUsed) begin
            forwardA = 2'b10;
        end
        if ((ID_EX_Rm == EX_MEM_Rd) && ID_EX_RmUsed) begin
            forwardB = 2'b10;
        end
    end
    // does not execute if EX/MEM forwarding (for edge case of two back-to-back EX/MEM forwarding)
    if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd31)) begin
        if ((ID_EX_Rn == MEM_WB_Rd) && ID_EX_RnUsed &&
            !((EX_MEM_RegWrite) && (EX_MEM_Rd != 5'd31) && ((ID_EX_Rn == EX_MEM_Rd)))) begin 
            forwardA = 2'b01;
        end
        if ((ID_EX_Rm == MEM_WB_Rd) && ID_EX_RmUsed &&
            !(EX_MEM_RegWrite && (EX_MEM_Rd != 5'd31) && ((ID_EX_Rm == EX_MEM_Rd)))) begin
            forwardB = 2'b01;
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
    if (ID_EX_MemWrite && (ID_EX_Rd != 5'd31)) begin
        if (ID_EX_Rd == EX_MEM_Rd) begin
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

end
endmodule


// Forwarding unit for write-BR hazards
module BR_forwarding (Br2Reg, ID_EX_RegWrite, EX_MEM_RegWrite, IF_ID_Rd, ID_EX_Rd, EX_MEM_Rd, forwardR_Rd);

input logic Br2Reg, ID_EX_RegWrite, EX_MEM_RegWrite;
input logic [4:0] IF_ID_Rd, ID_EX_Rd, EX_MEM_Rd;

// 00 = default (no forwarding)
// 01 = EX forwarding (raw alu result) 
// 10 = MEM forwarding (EX_MEM_alu_result) 
output logic [1:0] forwardR_Rd;


always_comb begin
    forwardR_Rd = 2'b00;

    if (Br2Reg && (IF_ID_Rd != 5'd31)) begin
        if (ID_EX_RegWrite && (IF_ID_Rd == ID_EX_Rd)) begin
            forwardR_Rd = 2'b01;
        end
        else if (EX_MEM_RegWrite && (IF_ID_Rd == EX_MEM_Rd)) begin
            forwardR_Rd = 2'b10;
        end
    end
end
endmodule
