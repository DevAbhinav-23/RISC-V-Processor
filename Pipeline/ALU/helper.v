module helper(
    input gi_not, pi_not,
    input gi_1_not, pi_1_not,
    output out_1, out_2
);
    wire inter;
    or(inter, gi_1_not, pi_not);
    nand(out_1, gi_not, inter);
    nor(out_2, pi_not, pi_1_not);
endmodule