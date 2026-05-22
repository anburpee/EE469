module cpu_control (opcode, is_zero, is_lt, Reg2Loc, UncondBranch, MemRead, MemtoReg, 
                    ALUOp, MemWrite, ALUSrc, RegWrite, SetFlags, isIType, Br2Reg, isBLT, isCBZ, IFFlush, RnUsed, RmUsed);

    input logic [10:0] opcode;
    input logic is_zero, is_lt;
    output logic Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, SetFlags, isIType, Br2Reg, isBLT, isCBZ, IFFlush, RnUsed, RmUsed;
    output logic [2:0] ALUOp;

    always_comb begin
        // default
        {Reg2Loc, UncondBranch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, SetFlags, isIType, Br2Reg, isBLT, isCBZ, IFFlush, RnUsed, RmUsed} = 18'b0;

        casez(opcode) 
            11'b1001000100?: begin // ADDI
                RegWrite = 1'b1; ALUSrc = 1'b1; isIType = 1'b1; RnUsed = 1'b1; ALUOp = 3'b010;
            end
            11'b10101011000: begin // ADDS
                RegWrite = 1'b1; SetFlags = 1'b1; RnUsed = 1'b1; RmUsed = 1'b1; ALUOp = 3'b010;
            end
            11'b000101?????: begin // B
                UncondBranch = 1'b1;
            end
            11'b01010100???: begin // B.LT
                isBLT=1'b1; 
            end
            11'b100101?????: begin // BL
                UncondBranch = 1'b1; RegWrite = 1'b1;
            end
            11'b11010110000: begin // BR
                Br2Reg = 1'b1; Reg2Loc = 1'b1;
            end
            11'b10110100???: begin // CBZ
                isCBZ = 1'b1; // use default ALUOp: pass B to evaluate zero flag
            end
            11'b11111000010: begin // LDUR
                MemRead = 1'b1; MemtoReg = 1'b1; ALUSrc = 1'b1; RegWrite = 1'b1; RnUsed = 1'b1; ALUOp = 3'b010;
            end
            11'b11111000000: begin // STUR
                Reg2Loc = 1'b1; MemWrite = 1'b1; ALUSrc = 1'b1; RnUsed = 1'b1; ALUOp = 3'b010;
            end
            11'b11101011000: begin // SUBS
                RegWrite = 1'b1; SetFlags = 1'b1; RnUsed = 1'b1; RmUsed = 1'b1; ALUOp = 3'b011;
            end
        endcase

        if ((isCBZ && is_zero) || (isBLT && is_lt) || UncondBranch || Br2Reg) begin
            IFFlush = 1'b1;
        end


    end
endmodule
