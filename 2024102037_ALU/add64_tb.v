`timescale 1ns/1ps

module tb_adder64;
    reg [63:0] A, B;
    wire [63:0] S;
    wire Cout;
    wire zero_flag, carry_flag, overflow_flag;
    reg [64:0] sum_ext;   // one extra bit for carry because this just stores A + B by direct addition operator of verilog to verify
    reg [63:0] sum_ref;
    reg carry_ref;
    reg zero_ref;
    reg overflow_ref;
    adder64 dut(
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
            sum_ext = {1'b0, A} + {1'b0, B};
            sum_ref = sum_ext[63:0];
            carry_ref = sum_ext[64];
            zero_ref = (sum_ref == 64'b0);
            overflow_ref = (~(A[63] ^ B[63])) & (A[63] ^ sum_ref[63]);
            if(S !== sum_ref || Cout !== carry_ref || carry_flag !== carry_ref || zero_flag !== zero_ref || overflow_flag !== overflow_ref) begin
                $display("FAIL");
                $display("A = %h, B = %h", A, B);
                $display("Expected: S=%h C=%b Z=%b O=%b", sum_ref, carry_ref, zero_ref, overflow_ref);
                $display("Got: S=%h C=%b Z=%b O=%b", S, Cout, zero_flag, overflow_flag);
            end
            else begin
                $display("PASS: A=%h B=%h S=%h O=%b C=%b", A, B, S, overflow_flag, carry_flag);
            end
        end
    endtask
  	initial begin
        $dumpfile("add64.vcd");
        $dumpvars(0, tb_adder64);
        apply_test(64'd0, 64'd0);
        apply_test(64'd1, 64'd1);
        apply_test(64'd10, 64'd20);

      	apply_test(64'hFFFFFFFFFFFFFFFF, 64'd1);
        apply_test(64'hFFFFFFFF00000000, 64'h0000000100000000);

        apply_test(64'h123456789ABCDEF0, -64'h123456789ABCDEF0);

        apply_test(64'h7FFFFFFFFFFFFFFF, 64'd1);   // +ve overflow
        apply_test(64'h8000000000000000, -64'd1);  // -ve overflow

        repeat(10) begin
            apply_test($random, $random);
        end
        $finish;
    end
endmodule