module alu_control(
    input  [1:0] alu_op,
    input  [3:0] instr,
    output reg [3:0] alu_c
);

    wire funct7_6 = instr[3];
    wire [2:0] funct3 = instr[2:0];

    always @(*) begin
        case (alu_op)
            2'b00:
                alu_c = 4'b0000;

            2'b01:
                alu_c = 4'b1000;

            2'b10:
                alu_c = {funct7_6, funct3};

            2'b11: begin
                if (funct3 == 3'b000)
                    alu_c = 4'b0000;
                else
                    alu_c = {funct7_6, funct3};
            end

            default:
                alu_c = 4'b0000;
        endcase
    end

endmodule
