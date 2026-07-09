module control(
    input [6:0] opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, jal, jalr,
    output reg [1:0] ALUOp
);

    localparam R = 7'b0110011;
    localparam I = 7'b0010011;
    localparam I_ld = 7'b0000011;
    localparam B = 7'b1100011;
    localparam S = 7'b0100011;
    localparam JAL = 7'b1101111;
    localparam JALR = 7'b1100111;

    // JAL, JALR need RegWrite = 1 and all other as 0
    // So, I just kept ALUOp = 10 for them which will satisfy our requirement

    always @(*) begin
        jal = 1'b0;
        jalr = 1'b0;
        if(opcode != 7'b0) begin
            case(opcode)
                R: ALUOp = 2'b10;
                I: ALUOp = 2'b11;
                I_ld: ALUOp = 2'b00;
                B: ALUOp = 2'b01;
                S: ALUOp = 2'b00;
                JAL: begin ALUOp = 2'b10; jal = 1'b1; end
                JALR: begin ALUOp = 2'b10; jalr = 1'b1; end
                default: ALUOp = 2'b00;
            endcase
            ALUSrc = ~(ALUOp[0] ^ ALUOp[1]);
            Branch = (~ALUOp[1]) & ALUOp[0];
            MemRead = ~((ALUOp[1] | ALUOp[0])) & (~opcode[5]);
            MemtoReg = ~((ALUOp[1] | ALUOp[0]));
            MemWrite = ~((ALUOp[1] | ALUOp[0])) & (opcode[5]);
            RegWrite = (~((ALUOp[1] | ALUOp[0])) & (~opcode[5])) | ALUOp[1];
        end
        else begin
            ALUOp = 2'b00;
            ALUSrc = 1'b0;
            Branch = 1'b0;
            MemRead = 1'b0;
            MemtoReg = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0;
        end
    end
endmodule