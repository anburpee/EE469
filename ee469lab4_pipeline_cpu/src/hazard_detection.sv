// Detects load-use hazards and write-store hazards
module hazard_detection (IF_ID_Rn, IF_ID_Rm, ID_EX_Rd, ID_EX_MemRead, RnUsed, RmUsed, isIType, MemWrite, MEM_WB_Rd, EX_MEM_Rd, EX_MEM_MemWrite, MEM_WB_RegWrite,
                         IF_ID_write, PCWrite, FlushCntrl, LoadUseRn, LoadUseRm, isWriteStore);

input logic [63:0] IF_ID_Rn, IF_ID_Rm, ID_EX_Rd;
input logic ID_EX_MemRead, RnUsed, RmUsed, isItype, MemWrite;

output logic IF_ID_write, PCWrite, LoadUseRn, LoadUseRm; // , isWriteStore;
output logic [1:0] FlushCntrl;



always_comb begin
    IF_ID_write = 1'b1;
    PCWrite = 1'b1;
    FlushCntrl = 1'b0;

    if (ID_EX_MemRead && (ID_EX_Rd != 5'd31) && ((ID_EX_Rd == IF_ID_Rn) && RnUsed || (ID_EX_Rd == IF_ID_Rm) && RmUsed)) begin
        IF_ID_write = 1'b0;
        PCWrite = 1'b0;
        FlushCntrl = 1'b1;
        if ((ID_EX_Rd == IF_ID_Rn) && RnUsed) begin
            LoadUseRn = 1'b1;
        end
        if ((ID_EX_Rd == IF_ID_Rm) && RmUsed) begin
            LoadUseRm = 1'b1;
        end
    end
end

// assign isWriteStore = (MEM_WB_Rd == EX_MEM_Rd) && EX_MEM_MemWrite && MEM_WB_RegWrite;

endmodule