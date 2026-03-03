module alu_control(
    input  [1:0] ALUOp,
    input  [3:0] instr,
    output  [3:0] alu_c
);

    wire funct7_6 = instr[3];
    wire [2:0] funct3 = instr[2:0];
    wire x;
    wire [3:0] y;
    assign x = (funct3[2] & (~funct3[1]) & funct3[0]) ? funct7_6 : 1'b0;
    assign y = (ALUOp[0] ^ ALUOp[1]) ? {funct7_6, funct3} : {x, funct3};
    assign alu_c = ~ALUOp[1] ? {ALUOp[0], 3'b0} : y;
endmodule