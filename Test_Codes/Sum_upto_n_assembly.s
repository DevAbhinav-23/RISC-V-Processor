addi x1, x0, 30      // n = 30
addi x2, x0, 0       // sum = 0
addi x3, x0, 1       // i = 1 (Loop variable)
add  x10, x3, x0     // x10 = 1 (temp)

Loop:
add  x2, x2, x3      // sum += i
addi x3, x3, 1       // i++
sub  x4, x3, x1      // i - n
beq  x4, x10, 8      // if i == n, branch to Exit
beq  x0, x0, -16      // branch to Loop (unconditional branch)

Exit: