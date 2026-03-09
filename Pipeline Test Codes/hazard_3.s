addi x1, x0, 20

sd   x1, 0(x0)

ld   x2, 0(x0)

sd   x2, 8(x0)       # store immediately after load

ld   x3, 8(x0)

add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0