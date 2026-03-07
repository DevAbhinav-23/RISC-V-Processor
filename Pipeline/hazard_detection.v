// stall = 1 means stall the pipeline (PC and IF/ID hold values)
// flush = 1 means flush the ID/EX control signals to NOP

module hazard_detection(
    input [4:0] rs1_IFID,
    input [4:0] rs2_IFID,
    input Branch_IFID,
    input [4:0] rd_IDEX,
    input MemRead_IDEX,
    input [4:0] rd_EXMEM,
    input MemRead_EXMEM,
    output reg stall
);
    always @(*) begin
        if(MemRead_IDEX && (rd_IDEX != 5'b0) && ((rd_IDEX == rs1_IFID) || (rd_IDEX == rs2_IFID)))
            stall = 1'b1;
        else if(Branch_IFID && MemRead_EXMEM && (rd_EXMEM != 5'b0) && ((rd_EXMEM == rs1_IFID) || (rd_EXMEM == rs2_IFID)))
            stall = 1'b1;
        else
            stall = 1'b0;
    end
endmodule
