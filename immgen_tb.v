`timescale 1ns/1ps

`include "immgen.v"

module immgen_tb;
    reg [31:0] instr;
    wire [63:0] imm;

    immgen uut (
        .instr(instr),
        .imm(imm)
    );

    integer pass_count = 0;
    integer fail_count = 0;

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
            if (imm === expected_imm) begin
                $display("Status: PASS");
                pass_count = pass_count + 1;
            end
            else begin
                $display("Status: FAIL");
                fail_count = fail_count + 1;
            end
            $display("");
        end
    endtask

    // Test sequence
    initial begin
        $display("========================================");
        $display("Immediate Generator Test Bench");
        $display("========================================");

        $display("\nTest 1: I-type immediate (addi)");
        decode_instruction(32'h00518193, 64'h0000000000000005, "addi x2, x3, 5");

        $display("\nTest 2: I-type with negative immediate");
        decode_instruction(32'hFFB18193, 64'hFFFFFFFFFFFFFFFB, "addi x2, x3, -5");

        $display("\nTest 3: I-type load (lw)");
        decode_instruction(32'h0041A103, 64'h0000000000000004, "lw x2, 4(x3)");

        $display("\nTest 4: S-type store (sw)");
        decode_instruction(32'h0021A223, 64'h0000000000000004, "sw x2, 4(x3)");

        $display("\nTest 5: S-type with larger immediate");
        decode_instruction(32'h0641A223, 64'h0000000000000064, "sw x2, 100(x3)");

        $display("\nTest 6: B-type branch (beq)");
        decode_instruction(32'h00208263, 64'h0000000000000002, "beq x1, x2, 8");

        $display("\nTest 7: B-type with negative offset");
        decode_instruction(32'hFE208CE3, 64'hFFFFFFFFFFFFFFFC, "beq x1, x2, -8");

        $display("\nTest 8: I-type shift immediate (slli)");
        decode_instruction(32'h00519193, 64'h0000000000000005, "slli x2, x3, 5");

        $display("\nTest 9: I-type shift immediate (srai)");
        decode_instruction(32'h40A1D193, 64'h000000000000000A, "srai x2, x3, 10");

        $display("\nTest 10: Load with negative offset");
        decode_instruction(32'hFFC1A103, 64'hFFFFFFFFFFFFFFFC, "lw x2, -4(x3)");

        $display("\nTest 11: Unknown opcode");
        decode_instruction(32'h00000000, 64'h0000000000000000, "Unknown opcode");

        $display("\nTest 12: Store with negative offset");
        decode_instruction(32'hFE21AA23, 64'hFFFFFFFFFFFFFFF4, "sw x2, -12(x3)");

        $display("========================================");
        $display("Test completed!");
        $display("========================================");
        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
