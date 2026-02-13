module pg_block(
    input ai, bi,
    output p_not, g_not, out
);
    nor(p_not, ai, bi);
    nand(g_not, ai, bi);
    xor(out, ai, bi);
endmodule