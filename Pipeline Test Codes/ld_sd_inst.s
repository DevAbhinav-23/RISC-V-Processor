addi x5, x0, 10         # x5 = 10 (base address)

addi x1, x0, 25         # x1 = 25
sd x1, 0(x5)            # memory[10] = 25   (initialize memory)

ld x2, 0(x5)            # x2 = memory[10] = 25
sd x2, 16(x5)           # LD → SD dependency (extra forwarding required)

ld x3, 16(x5)           # x3 should become 25 (verifies store worked)

add x0, x0, x0          # pipeline clearing
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0