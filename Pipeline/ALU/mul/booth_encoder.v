`timescale 1ns/1ps

// =============================================================================
// Radix-4 Booth Encoder
//
// Standard Radix-4 Booth encoding for multiplier digits.
// Each digit d_i = -2*b[2i+1] + b[2i] + b[2i-1]
// where b[-1]=0 (implicit).
//
// The 3-bit input y = {y2, y1, y0} maps to:
//   y2 = b[2i+1] (MSB of 2-bit group - determines sign)
//   y1 = b[2i]   (LSB of 2-bit group)
//   y0 = b[2i-1] (overlap from previous group)
//
// Output:
//   encode[1:0] = |digit| : 00=0, 01=1, 10=2
//   sign        = 1 if digit is negative (directly = y2)
//
// Encoding table:
//   y=000 ->  0       y=100 -> -2
//   y=001 -> +1       y=101 -> -1
//   y=010 -> +1       y=110 -> -1
//   y=011 -> +2       y=111 ->  0
// =============================================================================

module booth_encoder(
    input  [2:0] y,
    output [1:0] encode,
    output       sign
);
    assign sign = y[2];
    assign encode[0] = y[0] ^ y[1];
    assign encode[1] = (~y[2] & y[1] & y[0]) | (y[2] & ~y[1] & ~y[0]);
endmodule
