// stall = 1 means stall the pipeline (PC and IF/ID hold values)
// flush = 1 means flush the ID/EX control signals to NOP
// Always stall if rs1 matches, but only stall for rs2 if the instruction is NOT a Store.

module hazard_detection(
    input [4:0] rs1_IFID,
    input [4:0] rs2_IFID,
    input Branch_IFID, // need to know if it were a branch
    input MemWrite_IFID, // need to know if it were a store
    input [4:0] rd_IDEX,
    input MemRead_IDEX,
    input RegWrite_IDEX,
    input [4:0] rd_EXMEM,
    input MemRead_EXMEM,
    input jalr_IFID,
    output reg stall
);
    always @(*) begin
        if(MemRead_IDEX && (rd_IDEX != 5'b0) && (rd_IDEX == rs1_IFID)) // ld arithmetic dependecny
            stall = 1'b1;
        else if(MemRead_IDEX && (rd_IDEX != 5'b0) && (rd_IDEX == rs2_IFID) && !MemWrite_IFID) // ld sd not to stall thing
            stall = 1'b1;
        else if(Branch_IFID && RegWrite_IDEX && (rd_IDEX != 5'b0) && ((rd_IDEX == rs1_IFID) || (rd_IDEX == rs2_IFID))) // arithmetic beq
            stall = 1'b1;
        else if(Branch_IFID && MemRead_EXMEM && (rd_EXMEM != 5'b0) && ((rd_EXMEM == rs1_IFID) || (rd_EXMEM == rs2_IFID))) // ld beq
            stall = 1'b1;
        else if(jalr_IFID && RegWrite_IDEX && (rd_IDEX != 5'b0) && (rd_IDEX == rs1_IFID))
            stall = 1'b1;
        else if(jalr_IFID && MemRead_EXMEM && (rd_EXMEM != 5'b0) && (rd_EXMEM == rs1_IFID))
            stall = 1'b1;
        else
            stall = 1'b0;
    end
endmodule
