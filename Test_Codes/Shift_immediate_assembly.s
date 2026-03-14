    addi x1, x0, 0

    addi x4, x0, 1
    sd   x4, 0(x1)        # a = 1

    addi x4, x0, -8
    sd   x4, 8(x1)        # c = -8 (for arithmetic shift)

    addi x4, x0, -8
    sd   x4, 16(x1)       # e = -8 (for logical shift)

    ld   x6, 0(x1)        # x6 = a
    ld   x7, 8(x1)        # x7 = c
    ld   x8, 16(x1)       # x8 = e

    addi x9, x0, 40       # shift amount = 40 (imm[5:0])

    slli x10, x6, 40      # b = a << 40
    srai x11, x7, 40      # d = c >> 40 (arithmetic)
    srli x12, x8, 40      # f = e >> 40 (logical)
