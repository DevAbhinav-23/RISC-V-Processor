`timescale 1ns/1ps

`include "alu.v"
module alu_tb_main;


    reg  [63:0] a, b;
    reg [3:0] opcode;
    wire  [63:0] result;
    wire cout, carry_flag, overflow_flag, zero_flag;


    reg  [63:0] expected_result;
    reg expected_overflow, expected_carry, expected_zero;


    integer test_count;
    integer pass_count;
    integer fail_count;
    integer i;


    integer seed;


    localparam ADD_Oper  = 4'b0000;
    localparam SLL_Oper  = 4'b0001;
    localparam SLT_Oper  = 4'b0010;
    localparam SLTU_Oper = 4'b0011;
    localparam XOR_Oper  = 4'b0100;
    localparam SRL_Oper  = 4'b0101;
    localparam OR_Oper   = 4'b0110;
    localparam AND_Oper  = 4'b0111;
    localparam SUB_Oper  = 4'b1000;
    localparam SRA_Oper  = 4'b1101;


    localparam  [63:0] MAX_POS = 64'h7FFFFFFFFFFFFFFF;  // Maximum positive
    localparam  [63:0] MIN_NEG = 64'h8000000000000000;  // Minimum negative
    localparam  [63:0] ZERO    = 64'h0000000000000000;
    localparam  [63:0] NEG_ONE = 64'hFFFFFFFFFFFFFFFF;  // -1
    localparam  [63:0] POS_ONE = 64'h0000000000000001;  // 1


    alu_64_bit dut (
                   .a(a),
                   .b(b),
                   .opcode(opcode),
                   .result(result),
                   .cout(cout),
                   .carry_flag(carry_flag),
                   .overflow_flag(overflow_flag),
                   .zero_flag(zero_flag)
               );


    task check_result;
        input [255:0] test_name;
        input  [63:0] exp_res;
        input check_flags;
        begin
            test_count = test_count + 1;
            if (result === exp_res) begin
                pass_count = pass_count + 1;

            end
            else begin
                fail_count = fail_count + 1;
                $display("FAIL [%0d]: %s | a=%0d, b=%0d | Expected=%0d, Got=%0d | flags: ovf=%b, carry=%b, zero=%b",
                         test_count, test_name, a, b, exp_res, result, overflow_flag, carry_flag, zero_flag);
            end
        end
    endtask


    task test_add;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = ADD_Oper;
            #5;
            check_result("ADD", op_a + op_b, 1);
        end
    endtask


    task test_sub;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = SUB_Oper;
            #5;
            check_result("SUB", op_a - op_b, 1);
        end
    endtask


    task test_and;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = AND_Oper;
            #5;
            check_result("AND", op_a & op_b, 1);
        end
    endtask


    task test_or;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = OR_Oper;
            #5;
            check_result("OR", op_a | op_b, 1);
        end
    endtask


    task test_xor;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = XOR_Oper;
            #5;
            check_result("XOR", op_a ^ op_b, 1);
        end
    endtask


    task test_sll;
        input  [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = SLL_Oper;
            #5;
            check_result("SLL", op_a << op_b[5:0], 1);
        end
    endtask


    task test_srl;
        input  [63:0] op_a, op_b;
        reg [63:0] unsigned_a;
        begin
            a = op_a;
            b = op_b;
            opcode = SRL_Oper;
            #5;
            unsigned_a = op_a;
            check_result("SRL", unsigned_a >> op_b[5:0], 1);
        end
    endtask


    task test_sra;
        input signed [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = SRA_Oper;
            #5;
            check_result("SRA", op_a >>> op_b[5:0], 1);
        end
    endtask


    task test_slt;
        input signed [63:0] op_a, op_b;
        begin
            a = op_a;
            b = op_b;
            opcode = SLT_Oper;
            #5;
            check_result("SLT", (op_a < op_b) ? 64'd1 : 64'd0, 1);
        end
    endtask


    task test_sltu;
        input  [63:0] op_a, op_b;
        reg [63:0] unsigned_a, unsigned_b;
        begin
            a = op_a;
            b = op_b;
            opcode = SLTU_Oper;
            #5;
            unsigned_a = op_a;
            unsigned_b = op_b;
            check_result("SLTU", (unsigned_a < unsigned_b) ? 64'd1 : 64'd0, 1);
        end
    endtask


    initial begin
        $display("========================================");
        $display("    64-bit ALU Comprehensive Testbench");
        $display("========================================");
        $display("");


        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        seed = 12345;

        $display("--- Testing ADD Operation ---");


        test_add(64'd0, 64'd0);
        test_add(64'd1, 64'd1);
        test_add(64'd10, 64'd20);
        test_add(64'd100, 64'd200);
        test_add(64'd1000, 64'd2000);


        test_add(-64'd1, -64'd1);
        test_add(-64'd10, -64'd20);
        test_add(-64'd100, 64'd50);
        test_add(64'd100, -64'd50);
        test_add(-64'd100, -64'd200);


        test_add(MAX_POS, ZERO);
        test_add(ZERO, MAX_POS);
        test_add(MIN_NEG, ZERO);
        test_add(ZERO, MIN_NEG);
        test_add(MAX_POS, NEG_ONE);
        test_add(MIN_NEG, POS_ONE);
        test_add(MAX_POS, POS_ONE);  // Overflow case
        test_add(MIN_NEG, NEG_ONE);  // Underflow case


        for (i = 0; i < 63; i = i + 1) begin
            test_add(64'd1 << i, 64'd1);
            test_add(64'd1 << i, 64'd1 << i);
        end


        for (i = 0; i < 30; i = i + 1) begin
            test_add($random(seed), $random(seed));
            test_add({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing SUB Operation ---");


        test_sub(64'd0, 64'd0);
        test_sub(64'd10, 64'd5);
        test_sub(64'd100, 64'd50);
        test_sub(64'd1000, 64'd500);
        test_sub(64'd5, 64'd10);  // Negative result


        test_sub(-64'd10, -64'd5);
        test_sub(-64'd5, -64'd10);
        test_sub(-64'd100, 64'd50);
        test_sub(64'd100, -64'd50);
        test_sub(-64'd100, -64'd100);


        test_sub(MAX_POS, ZERO);
        test_sub(ZERO, MAX_POS);
        test_sub(MIN_NEG, ZERO);
        test_sub(ZERO, MIN_NEG);
        test_sub(MAX_POS, NEG_ONE);  // Overflow
        test_sub(MIN_NEG, POS_ONE);  // Underflow
        test_sub(MAX_POS, MAX_POS);  // Zero result
        test_sub(MIN_NEG, MIN_NEG);  // Zero result


        for (i = 0; i < 20; i = i + 1) begin
            test_sub({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end


        for (i = 1; i < 63; i = i + 1) begin
            test_sub(64'd1 << i, 64'd1 << (i-1));
        end


        for (i = 0; i < 30; i = i + 1) begin
            test_sub({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing AND Operation ---");


        test_and(64'd0, 64'd0);
        test_and(NEG_ONE, NEG_ONE);
        test_and(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555);
        test_and(64'hFFFF0000FFFF0000, 64'h0000FFFF0000FFFF);
        test_and(NEG_ONE, ZERO);
        test_and(ZERO, NEG_ONE);


        test_and(64'h123456789ABCDEF0, 64'h00000000FFFFFFFF);
        test_and(64'h123456789ABCDEF0, 64'hFFFFFFFF00000000);
        test_and(64'h123456789ABCDEF0, 64'h0F0F0F0F0F0F0F0F);
        test_and(64'h123456789ABCDEF0, 64'hF0F0F0F0F0F0F0F0);


        test_and(MAX_POS, NEG_ONE);
        test_and(MIN_NEG, NEG_ONE);
        test_and(MAX_POS, MAX_POS);
        test_and(MIN_NEG, MIN_NEG);


        for (i = 0; i < 80; i = i + 1) begin
            test_and({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing OR Operation ---");


        test_or(64'd0, 64'd0);
        test_or(NEG_ONE, NEG_ONE);
        test_or(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555);
        test_or(64'hFFFF0000FFFF0000, 64'h0000FFFF0000FFFF);
        test_or(NEG_ONE, ZERO);
        test_or(ZERO, NEG_ONE);


        test_or(64'h0000000000000000, 64'h8000000000000000);
        test_or(64'h0000000000000000, 64'h0000000000000001);
        test_or(64'h123456789ABCDEF0, 64'h00000000FFFFFFFF);


        test_or(MAX_POS, ZERO);
        test_or(MIN_NEG, ZERO);
        test_or(MAX_POS, MIN_NEG);


        for (i = 0; i < 85; i = i + 1) begin
            test_or({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing XOR Operation ---");


        test_xor(64'd0, 64'd0);
        test_xor(NEG_ONE, NEG_ONE);
        test_xor(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555);
        test_xor(64'hFFFF0000FFFF0000, 64'h0000FFFF0000FFFF);
        test_xor(NEG_ONE, ZERO);
        test_xor(ZERO, NEG_ONE);


        test_xor(64'h123456789ABCDEF0, 64'h123456789ABCDEF0);
        test_xor(MAX_POS, MAX_POS);
        test_xor(MIN_NEG, MIN_NEG);


        test_xor(64'h0F0F0F0F0F0F0F0F, NEG_ONE);


        for (i = 0; i < 88; i = i + 1) begin
            test_xor({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing SLL Operation ---");


        test_sll(64'd1, 64'd0);
        test_sll(64'd1, 64'd1);
        test_sll(64'd1, 64'd2);
        test_sll(64'd1, 64'd63);
        test_sll(NEG_ONE, 64'd1);
        test_sll(NEG_ONE, 64'd32);


        for (i = 0; i < 64; i = i + 1) begin
            test_sll(64'd1, i);
            test_sll(64'hDEADBEEFCAFEBABE, i);
        end


        test_sll(ZERO, 64'd32);
        test_sll(MAX_POS, 64'd1);
        test_sll(MIN_NEG, 64'd1);


        for (i = 0; i < 30; i = i + 1) begin
            test_sll({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
        end

        $display("--- Testing SRL Operation ---");


        test_srl(64'h8000000000000000, 64'd0);
        test_srl(64'h8000000000000000, 64'd1);
        test_srl(64'h8000000000000000, 64'd63);
        test_srl(NEG_ONE, 64'd1);
        test_srl(NEG_ONE, 64'd32);
        test_srl(NEG_ONE, 64'd63);


        for (i = 0; i < 64; i = i + 1) begin
            test_srl(64'h8000000000000000, i);
            test_srl(64'hDEADBEEFCAFEBABE, i);
        end


        for (i = 0; i < 30; i = i + 1) begin
            test_srl({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
        end

        $display("--- Testing SRA Operation ---");


        test_sra(64'h8000000000000000, 64'd0);
        test_sra(64'h8000000000000000, 64'd1);   // Should sign extend
        test_sra(64'h8000000000000000, 64'd63);  // Should be all 1s
        test_sra(64'h7FFFFFFFFFFFFFFF, 64'd1);   // Positive, should zero extend
        test_sra(NEG_ONE, 64'd1);
        test_sra(NEG_ONE, 64'd63);
        test_sra(-64'd8, 64'd3);  // -8 >> 3 = -1


        for (i = 0; i < 64; i = i + 1) begin
            test_sra(64'h8000000000000000, i);
            test_sra(64'hFEDCBA9876543210, i);
        end


        for (i = 0; i < 32; i = i + 1) begin
            test_sra(64'h7FFFFFFFFFFFFFFF, i);
        end


        for (i = 0; i < 30; i = i + 1) begin
            test_sra({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
        end

        $display("--- Testing SLT Operation ---");


        test_slt(64'd0, 64'd0);      // Equal
        test_slt(64'd0, 64'd1);      // Less
        test_slt(64'd1, 64'd0);      // Greater
        test_slt(-64'd1, 64'd0);     // Negative < Positive
        test_slt(64'd0, -64'd1);     // Positive > Negative
        test_slt(-64'd1, -64'd2);    // -1 > -2
        test_slt(-64'd2, -64'd1);    // -2 < -1


        test_slt(MAX_POS, MIN_NEG);  // Max > Min
        test_slt(MIN_NEG, MAX_POS);  // Min < Max
        test_slt(MAX_POS, MAX_POS);  // Equal
        test_slt(MIN_NEG, MIN_NEG);  // Equal
        test_slt(MAX_POS, 64'd0);
        test_slt(64'd0, MAX_POS);
        test_slt(MIN_NEG, 64'd0);
        test_slt(64'd0, MIN_NEG);


        test_slt(MAX_POS, NEG_ONE);
        test_slt(NEG_ONE, MAX_POS);
        test_slt(MIN_NEG, POS_ONE);
        test_slt(POS_ONE, MIN_NEG);


        for (i = -50; i < 50; i = i + 1) begin
            test_slt(i, i + 1);
            test_slt(i + 1, i);
            test_slt(i, i);
        end


        for (i = 0; i < 50; i = i + 1) begin
            test_slt({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Testing SLTU Operation ---");


        test_sltu(64'd0, 64'd0);
        test_sltu(64'd0, 64'd1);
        test_sltu(64'd1, 64'd0);
        test_sltu(64'd100, 64'd200);
        test_sltu(64'd200, 64'd100);


        test_sltu(-64'd1, 64'd0);     // Max unsigned > 0
        test_sltu(64'd0, -64'd1);     // 0 < Max unsigned
        test_sltu(-64'd1, -64'd2);    // Compare large unsigned
        test_sltu(-64'd2, -64'd1);


        test_sltu(MAX_POS, MIN_NEG);  // In unsigned: 0x7FFF... < 0x8000...
        test_sltu(MIN_NEG, MAX_POS);  // In unsigned: 0x8000... > 0x7FFF...
        test_sltu(NEG_ONE, ZERO);     // Max unsigned > 0
        test_sltu(ZERO, NEG_ONE);     // 0 < Max unsigned
        test_sltu(NEG_ONE, NEG_ONE);  // Equal


        for (i = 0; i < 100; i = i + 1) begin
            test_sltu(i, i + 1);
            test_sltu(i + 1, i);
            test_sltu(i, i);
        end


        for (i = 0; i < 50; i = i + 1) begin
            test_sltu({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
        end

        $display("--- Running Mixed Random Tests ---");

        for (i = 0; i < 120; i = i + 1) begin
            case (i % 10)
                0:
                    test_add({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                1:
                    test_sub({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                2:
                    test_and({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                3:
                    test_or({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                4:
                    test_xor({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                5:
                    test_sll({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
                6:
                    test_srl({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
                7:
                    test_sra({$random(seed), $random(seed)}, $random(seed) & 64'h3F);
                8:
                    test_slt({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
                9:
                    test_sltu({$random(seed), $random(seed)}, {$random(seed), $random(seed)});
            endcase
        end

        $display("--- Running Stress Tests ---");


        for (i = 0; i < 64; i = i + 1) begin
            test_add(64'd1 << i, 64'd1 << i);
            test_sub(64'd1 << i, 64'd1 << i);
            test_and(64'd1 << i, NEG_ONE);
            test_or(64'd1 << i, ZERO);
        end


        for (i = 0; i < 64; i = i + 1) begin
            test_and(~(64'd1 << i), NEG_ONE);
            test_or(~(64'd1 << i), ZERO);
        end


        test_add(MAX_POS, POS_ONE);
        test_sub(MIN_NEG, POS_ONE);
        test_add(NEG_ONE, POS_ONE);
        test_sub(ZERO, POS_ONE);

        $display("--- Running Flag Verification Tests ---");


        a = 64'd0;
        b = 64'd0;
        opcode = ADD_Oper;
        #5;
        if (zero_flag !== 1'b1)
            $display("FAIL: Zero flag not set for 0+0");

        a = 64'd100;
        b = -64'd100;
        opcode = ADD_Oper;
        #5;
        if (zero_flag !== 1'b1)
            $display("FAIL: Zero flag not set for 100+(-100)");

        a = 64'd100;
        b = 64'd100;
        opcode = SUB_Oper;
        #5;
        if (zero_flag !== 1'b1)
            $display("FAIL: Zero flag not set for 100-100");


        a = MAX_POS;
        b = POS_ONE;
        opcode = ADD_Oper;
        #5;
        if (overflow_flag !== 1'b1)
            $display("FAIL: Overflow flag not set for MAX_POS + 1");

        a = MIN_NEG;
        b = NEG_ONE;
        opcode = ADD_Oper;
        #5;
        if (overflow_flag !== 1'b1)
            $display("FAIL: Overflow flag not set for MIN_NEG + (-1)");


        a = MAX_POS;
        b = NEG_ONE;
        opcode = SUB_Oper;
        #5;
        if (overflow_flag !== 1'b1)
            $display("FAIL: Overflow flag not set for MAX_POS - (-1)");

        a = MIN_NEG;
        b = POS_ONE;
        opcode = SUB_Oper;
        #5;
        if (overflow_flag !== 1'b1)
            $display("FAIL: Overflow flag not set for MIN_NEG - 1");

        $display("");
        $display("");
        $display("========================================");
        $display("           TEST SUMMARY");
        $display("========================================");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("Pass Rate:    %0.2f%%", (pass_count * 100.0) / test_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end
        else begin
            $display("*** SOME TESTS FAILED - REVIEW REQUIRED ***");
        end

        $display("");
        $finish;
    end


    initial begin
        #1000000;
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule
