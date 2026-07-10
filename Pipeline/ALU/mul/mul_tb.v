`timescale 1ns/1ps

`include "booth_wallace_multiplier.v"

module mul_tb;

    reg  [63:0] a, b;
    wire [63:0] result;
    integer pass_count, fail_count;

    booth_wallace_multiplier dut(
        .a(a),
        .b(b),
        .result(result)
    );

    task check;
        input [63:0] exp;
        begin
            #1;
            if(result !== exp) begin
                fail_count = fail_count + 1;
                $display("FAIL | a[31:0]=%0d x b[31:0]=%0d -> got=%0d (0x%h) exp=%0d (0x%h)",
                         $signed(a[31:0]), $signed(b[31:0]),
                         $signed(result), result, $signed(exp), exp);
            end else begin
                pass_count = pass_count + 1;
                $display("PASS | a[31:0]=%0d x b[31:0]=%0d -> %0d",
                         $signed(a[31:0]), $signed(b[31:0]), $signed(result));
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("===========================================");
        $display("  Booth-Wallace Multiplier Testbench");
        $display("  32x32 -> 64-bit (lower 32 bits of each input)");
        $display("===========================================");
        $display("");

        $display("--- Basic Positive Multiplication ---");
        a = 64'd3;   b = 64'd5;  check(64'd15);
        a = 64'd7;   b = 64'd6;  check(64'd42);
        a = 64'd10;  b = 64'd10; check(64'd100);
        a = 64'd123; b = 64'd456;check(64'd56088);
        a = 64'd1;   b = 64'd1;  check(64'd1);
        a = 64'd0;   b = 64'd99; check(64'd0);
        a = 64'd99;  b = 64'd0;  check(64'd0);
        $display("");

        $display("--- Negative Multiplication ---");
        a = 64'hFFFFFFFFFFFFFFFD; b = 64'd5;  check(64'hFFFFFFFFFFFFFFF1); // -3 * 5 = -15
        a = 64'd3;   b = 64'hFFFFFFFFFFFFFFFB; check(64'hFFFFFFFFFFFFFFF1); // 3 * -5 = -15
        a = 64'hFFFFFFFFFFFFFFFD; b = 64'hFFFFFFFFFFFFFFFB; check(64'd15); // -3 * -5 = 15
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1;  check(64'hFFFFFFFFFFFFFFFF); // -1 * 1 = -1
        a = 64'd1;   b = 64'hFFFFFFFFFFFFFFFF; check(64'hFFFFFFFFFFFFFFFF); // 1 * -1 = -1
        $display("");

        $display("--- Powers of 2 ---");
        a = 64'd2;   b = 64'd2;   check(64'd4);
        a = 64'd4;   b = 64'd4;   check(64'd16);
        a = 64'd8;   b = 64'd8;   check(64'd64);
        a = 64'd16;  b = 64'd16;  check(64'd256);
        a = 64'd32;  b = 64'd32;  check(64'd1024);
        $display("");

        $display("--- Larger Values ---");
        a = 64'd1000; b = 64'd1000; check(64'd1000000);
        a = 64'd999;  b = 64'd999;  check(64'd998001);
        a = 64'd500;  b = 64'd500;  check(64'd250000);
        $display("");

        $display("--- Boundary / Signed Values ---");
        // 0xFFFFFFFF = -1 as signed32, 0xFFFFFFFF * 0xFFFFFFFF = 1
        a = 64'hFFFFFFFF; b = 64'hFFFFFFFF; check(64'd1);
        // -1 * 1 = -1
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; check(64'hFFFFFFFFFFFFFFFF);
        // INT32_MAX * 1
        a = 64'h7FFFFFFF; b = 64'd1; check(64'h7FFFFFFF);
        // -1 * INT32_MAX = -INT32_MAX
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h7FFFFFFF; check(64'hFFFFFFFF80000001);
        $display("");

        $display("===========================================");
        $display("TOTAL TESTS : %0d", pass_count + fail_count);
        $display("PASSED      : %0d", pass_count);
        $display("FAILED      : %0d", fail_count);
        $display("===========================================");

        if(fail_count == 0) $display("ALL TESTS PASSED");
        else                $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
