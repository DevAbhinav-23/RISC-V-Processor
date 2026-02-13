`include "ALU/alu.v"
`include "ALU/add64.v"
`include "mux.v"

module seq(
    input clk
);
    wire temp1, temp2; // couts of both the adders 
    wire [63:0] pc_out, pc_in; // pc block input and output
    wire [63:0] shift_left_out; // shift left by 2 immediate output
    wire [63:0] pc_mux_0, pc_mux_1; // pc_mux input signals

    adder64 pc_adder(
        .A(pc_out),
        .B(64'd4),
        .S(pc_mux_0),
        .Cin(1'b0),
        .Cout(temp1)
    );

    adder64 shift_adder(
        .A(pc_out),
        .B(shift_left_out),
        .S(pc_mux_1),
        .Cin(1'b0),
        .Cout(temp2)
    );
endmodule