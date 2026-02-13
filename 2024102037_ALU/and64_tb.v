`timescale 1ns/1ps

module tb_and64;
    reg [63:0] A, B;
    wire [63:0] C;
    wire zero_flag, carry_flag, overflow_flag, cout;
    reg [63:0] C_ref;
    reg zero_ref;
    and64 dut(
        .A(A),
        .B(B),
        .C(C),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .cout(cout)
    );
    task apply_test;
        input [63:0] a, b;
        begin
            A = a;
            B = b;
            #1;
            C_ref = A & B;
            zero_ref = (C_ref == 64'b0);
            if(C !== C_ref || zero_flag !== zero_ref || carry_flag !== 1'b0 || overflow_flag !== 1'b0) begin
                $display("FAIL");
                $display("A = %h, B = %h", A, B);
                $display("Expected: C=%h Z=%b C=%b V=%b",  C_ref, zero_ref, 1'b0, 1'b0);
                $display("Got: C=%h Z=%b C=%b V=%b",  C, zero_flag, carry_flag, overflow_flag);
            end
            else begin
                $display("PASS: A=%h B=%h C=%h", A, B, C);
            end
        end
    endtask
    initial begin
        $dumpfile("and64.vcd");
        $dumpvars(0, tb_and64);

        apply_test(64'd0, 64'd0);
        apply_test(64'hFFFFFFFFFFFFFFFF, 64'd0);
        apply_test(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF);
        apply_test(64'h123456789ABCDEF0, 64'h0F0F0F0F0F0F0F0F);
        apply_test(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555);

        repeat(10) begin
            apply_test($random, $random);
        end
        $finish;
    end
endmodule