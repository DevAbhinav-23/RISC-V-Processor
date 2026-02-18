module control(
    input [6:0] opcode,
    output Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output [1:0] ALUOp
);
    // I am following the RISC-V edition book convention guys, just go through the sections 4.3 and 4.4 of the TB to understand this
    // 00 is load/store, 01 is branch, 10 is for R format and 11 is for I format

    localparam R = 7'b0110011;
    localparam I = 7'b0010011;
    localparam I_ld = 7'b0000011;
    localparam B = 7'b1100011;
    localparam S = 7'b0100011;
    reg [1:0] ALUOp_reg;

    always @(*) begin
    case(opcode)
        R: ALUOp_reg = 2'b10;
        I: ALUOp_reg = 2'b11;
        I_ld:ALUOp_reg = 2'b00;
        B: ALUOp_reg = 2'b01;
        S: ALUOp_reg = 2'b00;
        default: ALUOp_reg = 2'b00;
    endcase
    end

    assign ALUOp = ALUOp_reg;
    assign ALUSrc = ~(ALUOp[0] ^ ALUOp[1]);
    assign Branch = (~ALUOp[1]) & ALUOp[0];
    assign MemRead = ~((ALUOp[1] | ALUOp[0])) & (~opcode[5]);
    assign MemtoReg =  ~((ALUOp[1] | ALUOp[0]));
    assign MemWrite = ~((ALUOp[1] | ALUOp[0])) & (opcode[5]);
    assign RegWrite = (~((ALUOp[1] | ALUOp[0])) & (~opcode[5])) | ALUOp[1];

endmodule