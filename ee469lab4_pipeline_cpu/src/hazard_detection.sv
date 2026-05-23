// Detects load-use hazards and load-BR hazards (flushing for when they're back-to-back)
module hazard_detection (IF_ID_Rn, IF_ID_Rm, IF_ID_Rd, ID_EX_Rd, ID_EX_MemRead, RnUsed, RmUsed, Br2Reg,
                         IF_ID_write, PCWrite, FlushCntrl, LoadUseRn, LoadUseRm, LoadBR);

input logic [4:0] IF_ID_Rn, IF_ID_Rm, IF_ID_Rd, ID_EX_Rd;
input logic ID_EX_MemRead, RnUsed, RmUsed, Br2Reg;

output logic IF_ID_write, PCWrite, LoadUseRn, LoadUseRm, LoadBR;
output logic FlushCntrl;



always_comb begin
    IF_ID_write = 1'b1;
    PCWrite = 1'b1;
    FlushCntrl = 1'b0;
    LoadUseRn = 1'b0;
    LoadUseRm = 1'b0;
    LoadBR = 1'b0;

    if (ID_EX_MemRead && (ID_EX_Rd != 5'd31) && 
        (((ID_EX_Rd == IF_ID_Rn) && RnUsed) || ((ID_EX_Rd == IF_ID_Rm) && RmUsed) || ((ID_EX_Rd == IF_ID_Rd) && Br2Reg))) begin 
        // IFFlush would override this IF_ID_write in the case of BR hazard but should be ok since PCWrite gets diabled
        IF_ID_write = 1'b0; 
        PCWrite = 1'b0;
        FlushCntrl = 1'b1;
        if ((ID_EX_Rd == IF_ID_Rn) && RnUsed) begin
            LoadUseRn = 1'b1;
        end
        if ((ID_EX_Rd == IF_ID_Rm) && RmUsed) begin
            LoadUseRm = 1'b1;
        end
        if ((ID_EX_Rd == IF_ID_Rd) && Br2Reg) begin
            LoadBR = 1'b1;
        end
    end
end

endmodule