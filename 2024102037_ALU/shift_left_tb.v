`timescale 1ns/1ps

module tb_sll64;
    reg [63:0] A, B;
    wire [63:0] S;
    wire cout, carry_flag, zero_flag, overflow_flag;
    reg [63:0] S_ref;
    reg zero_ref, overflow_ref;
    sll64 dut(
        .A(A),
        .B(B),
        .S(S),
        .cout(cout),
        .carry_flag(carry_flag),
        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag)
    );
    task apply_test;
        input [63:0] a, b;
        reg [5:0] shift;
        begin
            A = a;
            B = b;
            #1;
            shift = B[5:0];
            S_ref = A << shift;
            overflow_ref = A[63] ^ S_ref[63];
            zero_ref = (S_ref == 64'b0);
            if(S !== S_ref || cout !== 1'b0 || zero_flag !== zero_ref || carry_flag !== 1'b0 || overflow_flag !== overflow_ref) begin
                $display("FAIL");
                $display("A = %h, B = %h", A, B);
                $display("Expected: S=%h Z=%b C=%b V=%b", S_ref, zero_ref, 1'b0, overflow_ref);
                $display("Got: S=%h Z=%b C=%b V=%b", S, zero_flag, carry_flag, overflow_flag);
            end
            else begin
                $display("PASS: A=%h B=%h S=%h C=%h", A, B, S, carry_flag);
            end
        end
    endtask
    initial begin
        $dumpfile("sll64.vcd");
        $dumpvars(0, tb_sll64);

        apply_test(64'd0, 64'd0);
        apply_test(64'd1, 64'd1);
        apply_test(64'd1, 64'd65);

        apply_test(64'h0000000000000001, 64'd4);
        apply_test(64'h8000000000000000, 64'd1);

        apply_test(64'hFFFFFFFFFFFFFFFF, 64'd1);
        apply_test(64'h123456789ABCDEF0, 64'd8);

        repeat(20) begin
            apply_test($random, $random);
        end
        $finish;
    end
endmodule