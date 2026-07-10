`timescale 1ns/1ps

module booth_encoder(
    input  [2:0] y,
    output [1:0] encode,
    output       sign
);
    assign sign = y[2];
    assign encode[0] = y[0] ^ y[1];
    assign encode[1] = (~y[2] & y[1] & y[0]) | (y[2] & ~y[1] & ~y[0]);
endmodule

module test;
    reg [2:0] y;
    wire [1:0] enc;
    wire sgn;

    booth_encoder uut(.y(y), .encode(enc), .sign(sgn));

    initial begin
        $display("Booth Encoder Test:");
        $display("y    | sign enc | digit");
        $display("-----|----------|------");
        y = 3'b000; #1; $display("%b |   %b   %b  |  0", y, sgn, enc);
        y = 3'b001; #1; $display("%b |   %b   %b  | +1", y, sgn, enc);
        y = 3'b010; #1; $display("%b |   %b   %b  | +1", y, sgn, enc);
        y = 3'b011; #1; $display("%b |   %b   %b  | +2", y, sgn, enc);
        y = 3'b100; #1; $display("%b |   %b   %b  | -2", y, sgn, enc);
        y = 3'b101; #1; $display("%b |   %b   %b  | -1", y, sgn, enc);
        y = 3'b110; #1; $display("%b |   %b   %b  | -1", y, sgn, enc);
        y = 3'b111; #1; $display("%b |   %b   %b  |  0", y, sgn, enc);
        $finish;
    end
endmodule
