addi x1, x0, 10         # x1 = 10
sd   x1, 0(x0)          # store value to memory

ld   x2, 0(x0)          # load from memory
add  x3, x2, x1         # dependent on load → stall required

add  x4, x3, x1

add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0