`timescale 1ns/1ps

// ============================================================================
// Radix-4 Booth-Encoded Wallace Tree Multiplier
// 32x32 signed -> 64-bit (uses lower 32 bits of 64-bit inputs)
//
// Algorithm:
// 1. Sign-extend 32-bit inputs: A = a[31:0], B_ext = {b[31], b[31:0], 1'b0}
//    (35 bits: 2 sign-extended copies of b[31], then b[31:0], then B[-1]=0)
// 2. Booth-encode B_ext into 17 signed digits d[i] in {-2,-1,0,+1,+2}
//    Group i looks at B_ext[2i+2 : 2i]
// 3. For each digit, compute pp[i] = d[i] * A, sign-extend to 65 bits,
//    shift left by 2*i
// 4. Sum all 17 partial products (synthesis tool infers Wallace tree)
// 5. Take lower 64 bits of result
// ============================================================================

module booth_encoder(
    input  [2:0] y,
    output [1:0] encode,
    output       sign
);
    // Radix-4 Booth recoding: d = -2*y[2] + y[1] + y[0]
    assign sign = y[2];
    assign encode[0] = y[0] ^ y[1];
    assign encode[1] = (~y[2] & y[1] & y[0]) | (y[2] & ~y[1] & ~y[0]);
endmodule

module booth_wallace_multiplier(
    input  [63:0] a,
    input  [63:0] b,
    output [63:0] result
);
    // Only lower 32 bits used, sign-extended for signed multiplication
    wire [31:0] A = a[31:0];

    // 35-bit Booth input: {b[31], b[31], b[31:0], 1'b0}
    // This provides:
    //   B_ext[0]    = 0         (B[-1] for Booth recoding)
    //   B_ext[1..31]= b[0..30]  (original bits)
    //   B_ext[32]   = b[31]     (original MSB / sign bit)
    //   B_ext[33]   = b[31]     (1st sign extension)
    //   B_ext[34]   = b[31]     (2nd sign extension)
    wire [34:0] B_ext = {b[31], b[31], b[31:0], 1'b0};

    // ---- Booth Encoding (17 groups) ----
    // Group i uses B_ext[2i+2 : 2i]
    wire [1:0] enc [0:16];
    wire       sgn [0:16];

    booth_encoder be0  (.y(B_ext[2:0]),   .encode(enc[0]),  .sign(sgn[0]));
    booth_encoder be1  (.y(B_ext[4:2]),   .encode(enc[1]),  .sign(sgn[1]));
    booth_encoder be2  (.y(B_ext[6:4]),   .encode(enc[2]),  .sign(sgn[2]));
    booth_encoder be3  (.y(B_ext[8:6]),   .encode(enc[3]),  .sign(sgn[3]));
    booth_encoder be4  (.y(B_ext[10:8]),  .encode(enc[4]),  .sign(sgn[4]));
    booth_encoder be5  (.y(B_ext[12:10]), .encode(enc[5]),  .sign(sgn[5]));
    booth_encoder be6  (.y(B_ext[14:12]), .encode(enc[6]),  .sign(sgn[6]));
    booth_encoder be7  (.y(B_ext[16:14]), .encode(enc[7]),  .sign(sgn[7]));
    booth_encoder be8  (.y(B_ext[18:16]), .encode(enc[8]),  .sign(sgn[8]));
    booth_encoder be9  (.y(B_ext[20:18]), .encode(enc[9]),  .sign(sgn[9]));
    booth_encoder be10 (.y(B_ext[22:20]), .encode(enc[10]), .sign(sgn[10]));
    booth_encoder be11 (.y(B_ext[24:22]), .encode(enc[11]), .sign(sgn[11]));
    booth_encoder be12 (.y(B_ext[26:24]), .encode(enc[12]), .sign(sgn[12]));
    booth_encoder be13 (.y(B_ext[28:26]), .encode(enc[13]), .sign(sgn[13]));
    booth_encoder be14 (.y(B_ext[30:28]), .encode(enc[14]), .sign(sgn[14]));
    booth_encoder be15 (.y(B_ext[32:30]), .encode(enc[15]), .sign(sgn[15]));
    booth_encoder be16 (.y(B_ext[34:32]), .encode(enc[16]), .sign(sgn[16]));

    // ---- Partial Product Generation ----
    // val = |digit| * A, neg_val = -(|digit| * A)
    // Must sign-extend A to 34 bits for correct signed arithmetic
    // |digit|=1 -> val = A (34-bit signed)
    // |digit|=2 -> val = 2*A (34-bit signed)
    wire [33:0] A_sext = {{2{A[31]}}, A};          // 34-bit sign-extended A
    wire [33:0] A2     = {{1{A[31]}}, A, 1'b0};    // 34-bit sign-extended 2*A

    // For each group i:
    //   spv = sgn ? neg_val : val   (signed 34-bit Booth digit times A)
    //   pp[i] = sign_extend_65(spv) << (2*i)
    // Implemented by: extend spv to 96 bits, shift, take [64:0]

    wire [64:0] pp [0:16];

    genvar i;
    generate
        for (i = 0; i < 17; i = i + 1) begin : pp_gen
            wire [33:0] val_i     = enc[i][1] ? A2 : (enc[i][0] ? A_sext : 34'b0);
            wire [33:0] neg_val_i = ~val_i + 34'd1;
            wire [33:0] spv       = sgn[i] ? neg_val_i : val_i;

            // Sign-extend spv to 96 bits, shift left by 2*i, take lower 65 bits
            wire [95:0] ext     = {{32{spv[33]}}, spv};
            wire [95:0] shifted = ext << (2 * i);
            assign pp[i] = shifted[64:0];
        end
    endgenerate

    // ---- Wallace Tree / Compressor Summation ----
    // Behavioral sum: synthesis tools infer optimal CSA tree
    assign result = pp[0]  + pp[1]  + pp[2]  + pp[3]
                  + pp[4]  + pp[5]  + pp[6]  + pp[7]
                  + pp[8]  + pp[9]  + pp[10] + pp[11]
                  + pp[12] + pp[13] + pp[14] + pp[15]
                  + pp[16];

endmodule
