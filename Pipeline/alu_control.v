module alu_control(
    input  [1:0] ALUOp,
    input  [4:0] instr,
    output  [3:0] alu_c
);

    // instr = {funct7[5], funct7[0], funct3[2:0]}
    // For R-type (ALUOp=2'b10):
    //   ADD:  funct7=0000000, funct3=000 -> instr=5'b00_000
    //   SUB:  funct7=0100000, funct3=000 -> instr=5'b10_000
    //   MUL:  funct7=0000001, funct3=000 -> instr=5'b01_000
    //   SLL:  funct7=0000000, funct3=001 -> instr=5'b00_001
    //   SLT:  funct7=0000000, funct3=010 -> instr=5'b00_010
    //   SLTU: funct7=0000000, funct3=011 -> instr=5'b00_011
    //   XOR:  funct7=0000000, funct3=100 -> instr=5'b00_100
    //   SRL:  funct7=0000000, funct3=101 -> instr=5'b00_101
    //   SRA:  funct7=0100000, funct3=101 -> instr=5'b10_101
    //   OR:   funct7=0000000, funct3=110 -> instr=5'b00_110
    //   AND:  funct7=0000000, funct3=111 -> instr=5'b00_111

    wire funct7_5   = instr[4];  // funct7[5] = instruction bit 30
    wire funct7_0   = instr[3];  // funct7[0] = instruction bit 25
    wire [2:0] funct3 = instr[2:0];

    // Detect MUL: R-type with funct7=0000001, funct3=000
    wire is_mul = (ALUOp == 2'b10) && (funct7_5 == 1'b0) && (funct7_0 == 1'b1) && (funct3 == 3'b000);

    // For non-MUL R-type/I-type: original encoding {funct7[5], funct3}
    wire funct7_6 = funct7_5; // backward compat: renamed but same bit
    wire x;
    wire [3:0] y;
    assign x = (funct3[2] & (~funct3[1]) & funct3[0]) ? funct7_6 : 1'b0;
    assign y = (ALUOp[0] ^ ALUOp[1]) ? {funct7_6, funct3} : {x, funct3};

    // MUL gets opcode 4'b1001
    assign alu_c = is_mul ? 4'b1001 :
                   ~ALUOp[1] ? {ALUOp[0], 3'b0} : y;
endmodule
