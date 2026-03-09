addi x1, x0, 5          # x1 = 5
addi x2, x0, 5          # x2 = 5

add  x3, x1, x2         # x3 = 10

beq  x3, x2, 8          # branch should NOT be taken (10 != 5)
add  x4, x3, x1         # executed

add  x5, x1, x1         # x5 = 10

beq  x5, x3, 8          # branch SHOULD be taken (10 == 10)
add  x6, x0, x0         # should be skipped

add  x7, x3, x2         # executed after branch

add x0, x0, x0          # pipeline NOPs
add x0, x0, x0
add x0, x0, x0