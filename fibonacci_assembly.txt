// Fibonacci
// Calculate first n Fibonacci numbers

    addi x1, x0, 10       // n = 10
    addi x2, x0, 0        // base address for storing results (byte address)

    addi x3, x0, 0        // Fib(0) = 0
    addi x4, x0, 1        // Fib(1) = 1

    sd x3, 0(x2)          // store Fib(0)
    addi x2, x2, 8

    sd x4, 0(x2)          // store Fib(1)
    addi x2, x2, 8

    addi x5, x0, 2        // i = 2

fib_loop:
    beq x5, x1, 32        // if i == n, jump to fib_done

    add x6, x3, x4        // next = a + b
    sd x6, 0(x2)          // store next
    addi x2, x2, 8

    addi x5, x5, 1        // i++
    add x3, x0, x4        // a = b
    add x4, x0, x6        // b = next

    beq x0, x0, -28       // jump back to fib_loop

fib_done:
    addi x2, x0, 0        // reset address pointer

    ld x10, 0(x2)         // load Fibonacci numbers
    ld x11, 8(x2)
    ld x12, 16(x2)
    ld x13, 24(x2)
    ld x14, 32(x2)
    ld x15, 40(x2)
    ld x16, 48(x2)
    ld x17, 56(x2)
    ld x18, 64(x2)
    ld x19, 72(x2)
