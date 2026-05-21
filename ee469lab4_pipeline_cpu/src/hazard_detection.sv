// Detects load-use hazards hazards
module hazard_detection (IF_ID_Rn, IF_ID_Rm, ID_EX_Rd, ID_EX_MemRead, RnUsed, RmUsed,
                         IF_ID_write, PCWrite, FlushCntrl, LoadUseRn, LoadUseRm);

input logic [4:0] IF_ID_Rn, IF_ID_Rm, ID_EX_Rd;
input logic ID_EX_MemRead, RnUsed, RmUsed;

output logic IF_ID_write, PCWrite, LoadUseRn, LoadUseRm;
output logic FlushCntrl;



always_comb begin
    IF_ID_write = 1'b1;
    PCWrite = 1'b1;
    FlushCntrl = 1'b0;
    LoadUseRn = 1'b0;
    LoadUseRm = 1'b0;

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

endmodule