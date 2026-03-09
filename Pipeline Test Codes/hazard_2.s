addi x1, x0, 10        # x1 = 10
sd   x1, 0(x0)         # memory[0] = 10

ld   x2, 0(x0)         # x2 = 10

beq  x2, x1, 8         # branch depends on load result → stall required

add  x3, x0, x0        # should be skipped if branch taken

add  x4, x1, x2        # executed after branch

add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0