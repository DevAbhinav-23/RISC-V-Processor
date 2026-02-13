`timescale 1ns/1ps

module tb_slt64;
    reg [63:0] A, B;
    wire [63:0] S;
    wire Cout, zero_flag, carry_flag, overflow_flag;
    reg [63:0] S_ref;
    reg zero_ref;
    slt64 dut(
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
            if($signed(A) < $signed(B))
                S_ref = 64'd1;
            else
                S_ref = 64'd0;
            zero_ref = ~S_ref[0];
            if(S !== S_ref || Cout !== 1'b0 || zero_flag !== zero_ref || carry_flag !== 1'b0 || overflow_flag !== 1'b0) begin
                $display("FAIL");
                $display("A = %h, B = %h", A, B);
                $display("Expected: S=%h Z=%b C=%b V=%b", S_ref, zero_ref, 1'b0, 1'b0);
                $display("Got: S=%h Z=%b C=%b V=%b", S, zero_flag, carry_flag, overflow_flag);
            end
            else begin
                $display("PASS: A=%h B=%h S=%h", A, B, S);
            end
        end
    endtask

    initial begin
        $dumpfile("slt64.vcd");
        $dumpvars(0, tb_slt64);

        apply_test(64'd0, 64'd0);
        apply_test(64'd1, 64'd2);
        apply_test(64'd2, 64'd1);

        apply_test(-64'd1, 64'd1);
        apply_test(64'd1, -64'd1);

        apply_test(64'h7FFFFFFFFFFFFFFF, 64'h8000000000000000);
        apply_test(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF);

        repeat(20) begin
            apply_test($random, $random);
        end
        $finish;
    end
endmodule