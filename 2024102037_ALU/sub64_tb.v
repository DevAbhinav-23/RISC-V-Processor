`timescale 1ns/1ps

module tb_sub64;
    reg  [63:0] A, B;
    wire [63:0] S;
    wire Cout;
    wire zero_flag, carry_flag, overflow_flag;
    reg  [64:0] diff_ext; // Reference subtraction, that is why there are 65 bits here

    reg  [63:0] diff_ref; 
    reg  borrow_ref;
    reg  zero_ref;
    reg  overflow_ref;
    sub64 dut(
        .A(A),
        .B(B),
        .S(S),
        .Cout(Cout),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag)
    );
    task apply_test;
        input [63:0] a, b;
        begin
            A = a;
            B = b;
            #1;
            diff_ext  = {1'b0, A} - {1'b0, B};
            diff_ref  = diff_ext[63:0];
            // diff_ext[64] == 1 -> borrow occurred
            // diff_ext[64] == 0 -> no borrow
            borrow_ref = diff_ext[64];
            zero_ref = (diff_ref == 64'b0);
            overflow_ref = (A[63] ^ B[63]) & (A[63] ^ diff_ref[63]);
            if(S !== diff_ref || Cout !== ~borrow_ref || carry_flag !== borrow_ref || zero_flag !== zero_ref || overflow_flag !== overflow_ref) begin
                $display("FAIL");
                $display("A = %h, B = %h", A, B);
                $display("Expected: S=%h Cout=%b CF=%b Z=%b V=%b", diff_ref, ~borrow_ref, borrow_ref, zero_ref, overflow_ref);
                $display("Got: S=%h Cout=%b CF=%b Z=%b V=%b", S, Cout, carry_flag, zero_flag, overflow_flag);
            end
            else begin
                $display("PASS: A=%h B=%h S=%h Carry Flag=%h Overflow Flag=%h Cout=%h", A, B, S, carry_flag, overflow_flag, Cout);
            end
        end
    endtask
    initial begin
        $dumpfile("sub64.vcd");
        $dumpvars(0, tb_sub64);

        apply_test(64'd0, 64'd0);
        apply_test(64'd10, 64'd3);
        apply_test(64'd3, 64'd10);

        apply_test(64'h8000000000000000, 64'd1);
        apply_test(64'h7FFFFFFFFFFFFFFF, -64'd1);

        apply_test(64'h123456789ABCDEF0, 64'h123456789ABCDEF0);

        repeat (10) begin
            apply_test($random, $random);
        end
        $finish;
    end
endmodule