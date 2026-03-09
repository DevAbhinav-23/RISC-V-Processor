addi x1, x0, 5
addi x2, x0, 16

add  x3, x1, x2
add  x4, x3, x1
sub  x5, x4, x2
and  x6, x5, x3

or   x7, x6, x4
add  x8, x7, x3

sd   x8, 0(x2)
ld   x9, 0(x2)

add  x10, x9, x1

add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0