addi x5, x0, 5
addi x6, x0, 0
addi x7, x0, 0
outer_loop:
sub x10, x6, x5
beq x10, x0, 36
addi x8, x0, 0
inner_loop:
sub x11, x8, x5
beq x11, x0, 16
addi x7, x7, 1
addi x8, x8, 1
beq x0, x0, -16
next_outer:
addi x6, x6, 1
beq x0, x0, -36
done:
