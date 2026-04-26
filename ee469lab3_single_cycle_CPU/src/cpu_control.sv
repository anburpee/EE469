module cpu_control (opcode, Reg2Loc, Uncondbranch, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, Br2Reg, CBZ);

    input logic [10:0] opcode;
    output logic Reg2Loc, Uncondbranch, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, SetFlags, Br2Reg, CBZ;
    output logic [2:0] ALUOp;

    always_comb begin
        // default
        {Reg2Loc, Uncondbranch, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, SetFlags, Br2Reg, CBZ} = 13'b0;

        casez(opcode) 
            11'b1001000100?: begin // ADDI
                RegWrite = 1'b1; ALUOp = 3'b010;
            end
            11'b10101011000: begin // ADDS
                RegWrite = 1'b1; SetFlags = 1'b1; ALUOp = 3'b010;
            end
            11'b000101?????: begin // B
                UncondBranch = 1'b1; Branch = 1'b1;
            end
            11'b01010100???: begin // B.LT
                Branch=1'b1; 
            end
            11'b100101?????: begin // BL
                UncondBranch = 1'b1; Branch = 1'b1;
            end
            11'b11010110000: begin // BR
                Br2Reg = 1'b1; Reg2Loc = 1'b1;
            end
            11'b10110100???: begin // CBZ
                Branch = 1'b1; CBZ = 1'b1; // use default ALUOp: pass B to evaluate zero flag
            end
            11'b11111000010: begin // LDUR
                MemRead = 1'b1; MemtoReg = 1'b1; ALUSrc = 1'b1; RegWrite = 1'b1; ALUOp = 3'b010;
            end
            11'b11111000000: begin // STUR
                Reg2Loc = 1'b1; MemWrite = 1'b1; ALUSrc = 1'b1; ALUOp = 1'b010;
            end
            11'b11101011000: begin // SUBS
                RegWrite = 1'b1; SetFlags = 1'b1; ALUOp = 3'b011
            end
        endcase


    end
endmodule
