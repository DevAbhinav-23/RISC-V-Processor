`timescale 1ns/1ps

module alu_64_bit_tb;
    reg  [63:0] a, b;
    reg  [3:0]  opcode;
    wire [63:0] result;
    wire zero_flag;
    integer pass_count = 0;
    integer fail_count = 0;
    alu_64_bit dut(
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .zero_flag(zero_flag)
    );
    localparam ADD  = 4'b0000,
               SLL  = 4'b0001,
               SLT  = 4'b0010,
               SLTU = 4'b0011,
               XOR  = 4'b0100,
               SRL  = 4'b0101,
               OR   = 4'b0110,
               AND  = 4'b0111,
               SUB  = 4'b1000,
               SRA  = 4'b1101;
    task check;
        input [63:0] exp;
        begin
            #1;
            if(result !== exp) begin
                fail_count = fail_count + 1;
                $display("FAIL | op=%h a=%h b=%h -> got=%h exp=%h", opcode, a, b, result, exp);
            end else begin
                pass_count = pass_count + 1;
                $display("PASS | op=%h a=%h b=%h -> %h", opcode, a, b, result);
            end
        end
    endtask

    initial begin
        $display("------------ ALU 64-BIT TEST START ------------");
        opcode = ADD;
        a = 64'h0; b = 64'h0; check(64'h0);
        a = 64'h1; b = 64'h1; check(64'h2);
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h1; check(64'h0);
        a = 64'h7FFFFFFFFFFFFFFF; b = 64'h1; check(64'h8000000000000000);
        $display("ADD Done\n");

        opcode = SUB;
        a = 64'h5; b = 64'h3; check(64'h2);
        a = 64'h3; b = 64'h5; check(64'hFFFFFFFFFFFFFFFE);
        a = 64'h0; b = 64'h0; check(64'h0);
        $display("SUB Done\n");

        opcode = SLT;
        a = 64'h7FFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; check(64'h0);
        a = 64'hFFFFFFFFFFFFFFFF;  b = 64'h7FFFFFFFFFFFFFFF;  check(64'h1);
        a = 64'h5; b = 64'h6; check(64'h1);
        a = 64'h6; b = 64'h5; check(64'h0);
        a = 64'hFFFFFFFFFFFFFFF0; b = 64'hFFFFFFFFFFFFFFF1; check(64'h1);
        $display("SLT Done\n");

        opcode = SLTU;
        a = 64'h5; b = 64'h6; check(64'h1);
        a = 64'h6; b = 64'h5; check(64'h0);
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0; check(64'h0);
        $display("SLTU Done\n");

        opcode = XOR;
        a = 64'h0; b = 64'h0; check(64'h0);
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0; check(64'hFFFFFFFFFFFFFFFF);
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; check(64'hFFFFFFFFFFFFFFFF);
        $display("XOR Done\n");

        opcode = OR;
        a = 64'h0; b = 64'h0; check(64'h0);
        a = 64'h1234; b = 64'hABCD; check(64'hBBFD);
        $display("OR Done\n");

        opcode = AND;
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0; check(64'h0);
        a = 64'hF0F0F0F0F0F0F0F0; b = 64'h0F0F0F0F0F0F0F0F; check(64'h0);
        $display("AND Done\n");

        opcode = SLL;
        a = 64'h1; b = 64'h1; check(64'h2);
        a = 64'h1; b = 64'h3; check(64'h8);
        $display("SLL Done\n");

        opcode = SRL;
        a = 64'h8000000000000000; b = 64'h1; check(64'h4000000000000000);
        $display("SRL Done\n");

        opcode = SRA;
        a = 64'h8000000000000000; b = 64'h1; check(64'hC000000000000000);
        $display("SRA Done\n");

        opcode = 4'hF;
        a = 64'h1234; b = 64'h5678; check(64'h0);
        $display("Invalid 4 bit control signal Done\n");

        $display("-------------------------------------------");
        $display("TOTAL TESTS : %0d", pass_count + fail_count);
        $display("PASSED      : %0d", pass_count);
        $display("FAILED      : %0d", fail_count);
        $display("-------------------------------------------");

        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule