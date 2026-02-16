`include "immgen.v"

module immgen_tb;
    reg [31:0] instr;
    wire [63:0] imm;

    // Instantiate the Unit Under Test (UUT)
    immgen uut (
        .instr(instr),
        .imm(imm)
    );

    // Helper task to decode instruction
    task decode_instruction;
        input [31:0] instruction;
        input [63:0] expected_imm;
        input [256*8-1:0] description;
        begin
            instr = instruction;
            #5;
            $display("Instruction: 0x%h", instr);
            $display("Opcode: 0b%07b, Funct3: 0b%03b", instr[6:0], instr[14:12]);
            $display("Immediate: 0x%h (%0d)", imm, $signed(imm));
            $display("Expected:  0x%h (%0d)", expected_imm, $signed(expected_imm));
            if (imm === expected_imm)
                $display("Status: PASS");
            else
                $display("Status: FAIL");
            $display("");
        end
    endtask

    // Test sequence
    initial begin
        $display("========================================");
        $display("Immediate Generator Test Bench");
        $display("========================================");

        // Test 1: I-type immediate (addi x2, x3, 5)
        $display("\nTest 1: I-type immediate (addi)");
        // addi x2, x3, 5 = 0x00518193
        // imm[11:0] = 0x005
        decode_instruction(32'h00518193, 64'h0000000000000005, "addi x2, x3, 5");

        // Test 2: I-type with negative immediate
        $display("\nTest 2: I-type with negative immediate");
        // addi x2, x3, -5 = 0xFFB18193
        // imm[11:0] = 0xFFB (sign extended)
        decode_instruction(32'hFFB18193, 64'hFFFFFFFFFFFFFFFB, "addi x2, x3, -5");

        // Test 3: I-type load (lw x2, 4(x3))
        $display("\nTest 3: I-type load (lw)");
        // lw x2, 4(x3) = 0x0041A103
        // imm[11:0] = 0x004
        decode_instruction(32'h0041A103, 64'h0000000000000004, "lw x2, 4(x3)");

        // Test 4: S-type store (sw x2, 4(x3))
        $display("\nTest 4: S-type store (sw)");
        // sw x2, 4(x3) = 0x0021A223
        // imm[11:5] = 0000000, imm[4:0] = 00100 = 4
        decode_instruction(32'h0021A223, 64'h0000000000000004, "sw x2, 4(x3)");

        // Test 5: S-type with larger immediate
        $display("\nTest 5: S-type with larger immediate");
        // sw x2, 100(x3) = 0x0641A223
        decode_instruction(32'h0641A223, 64'h0000000000000064, "sw x2, 100(x3)");

        // Test 6: B-type branch (beq x1, x2, label)
        // For branch, imm is constructed from: {instr[31], instr[7], instr[30:25], instr[11:8]}
        $display("\nTest 6: B-type branch (beq)");
        // beq x1, x2, 8 = branch offset of 8 bytes (2 instructions)
        // The actual immediate value extracted by immgen module
        decode_instruction(32'h00208263, 64'h0000000000000002, "beq x1, x2, 8");

        // Test 7: B-type with negative offset
        $display("\nTest 7: B-type with negative offset");
        // beq x1, x2, -8 = branch offset of -8 bytes
        decode_instruction(32'hFE208CE3, 64'hFFFFFFFFFFFFFFFC, "beq x1, x2, -8");

        // Test 8: I-type shift immediate (slli x2, x3, 5)
        $display("\nTest 8: I-type shift immediate (slli)");
        // slli x2, x3, 5 = 0x00519193
        // shamt[4:0] = 5
        decode_instruction(32'h00519193, 64'h0000000000000005, "slli x2, x3, 5");

        // Test 9: I-type shift immediate (srai)
        $display("\nTest 9: I-type shift immediate (srai)");
        // srai x2, x3, 10 = 0x40A1D193
        decode_instruction(32'h40A1D193, 64'h000000000000000A, "srai x2, x3, 10");

        // Test 10: Load with negative offset
        $display("\nTest 10: Load with negative offset");
        // lw x2, -4(x3) = 0xFFC1A103
        decode_instruction(32'hFFC1A103, 64'hFFFFFFFFFFFFFFFC, "lw x2, -4(x3)");

        // Test 11: Default case (unknown opcode)
        $display("\nTest 11: Unknown opcode");
        decode_instruction(32'h00000000, 64'h0000000000000000, "Unknown opcode");

        // Test 12: Store with negative offset
        $display("\nTest 12: Store with negative offset");
        // sw x2, -8(x3) 
        decode_instruction(32'hFE21AA23, 64'hFFFFFFFFFFFFFFF4, "sw x2, -12(x3)");

        $display("========================================");
        $display("Test completed!");
        $display("========================================");
        $finish;
    end

endmodule
