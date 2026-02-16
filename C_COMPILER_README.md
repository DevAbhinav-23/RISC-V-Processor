# RISC-V C Compiler using LLVM/Clang

This C compiler uses LLVM/Clang to compile C code to RISC-V assembly, then assembles it to binary machine code for the processor.

## Prerequisites

### Install LLVM/Clang with RISC-V support

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install clang lld llvm
```

**macOS (using Homebrew):**
```bash
brew install llvm
# Add to PATH: export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
```

**Arch Linux:**
```bash
sudo pacman -S clang llvm
```

**Fedora:**
```bash
sudo dnf install clang llvm
```

### Verify Installation

```bash
python c_compiler.py --check
```

## Usage

### Basic Usage

```bash
python c_compiler.py program.c instructions.txt
```

### Command Line Options

```
python c_compiler.py [options] <input.c> [output.txt]

Options:
  -march ARCH          RISC-V architecture (default: rv64i)
                       Options: rv32i, rv64i, rv32im, rv64im, etc.
  -mabi ABI            RISC-V ABI (ilp32, lp64, etc.)
  -O LEVEL             Optimization level (0, 1, 2, 3, s)
  --keep-asm           Keep intermediate assembly file
  --check              Check if clang is available
  -h, --help           Show help message
```

### Examples

**Compile with default settings:**
```bash
python c_compiler.py program.c
```

**Compile for 32-bit RISC-V:**
```bash
python c_compiler.py -march=rv32i program.c instructions.txt
```

**Compile with optimization:**
```bash
python c_compiler.py -O2 program.c instructions.txt
```

**Keep assembly file for inspection:**
```bash
python c_compiler.py --keep-asm program.c instructions.txt
# Creates: program.s
```

## Supported C Features

Since this targets a bare-metal RISC-V processor without standard library support:

### Supported:
- Basic arithmetic (+, -, *, /, %)
- Bitwise operations (&, |, ^, ~, <<, >>)
- Comparisons (==, !=, <, >, <=, >=)
- Control flow (if/else, for, while, do-while)
- Functions (with limited calling convention)
- Global and local variables
- Arrays
- Pointers

### Not Supported:
- Standard library functions (printf, malloc, etc.)
- Floating point operations (without F extension)
- System calls
- Dynamic memory allocation
- Complex data structures (structs, unions, enums - basic support only)

## Example C Programs

### Example 1: Simple Arithmetic

```c
// simple_math.c
int main() {
    int a = 10;
    int b = 20;
    int c = a + b;
    int d = a - b;
    int e = a * b;
    return c;
}
```

Compile:
```bash
python c_compiler.py simple_math.c instructions.txt
```

### Example 2: Loop

```c
// loop.c
int main() {
    int sum = 0;
    for (int i = 0; i < 10; i++) {
        sum = sum + i;
    }
    return sum;
}
```

### Example 3: Array Access

```c
// array.c
int main() {
    int arr[5];
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    arr[3] = 4;
    arr[4] = 5;
    return arr[0] + arr[4];
}
```

### Example 4: Function Call

```c
// function.c
int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    int y = 10;
    int result = add(x, y);
    return result;
}
```

## How It Works

1. **C to Assembly**: Uses `clang` with RISC-V target to compile C to assembly
   ```
   clang --target=riscv64-unknown-elf -march=rv64i -S -O0 input.c -o output.s
   ```

2. **Assembly Processing**: Processes clang output to remove directives and adapt to our assembler syntax

3. **Assembly to Binary**: Uses our custom RISC-V assembler to generate machine code
   ```
   python assembler.py output.s instructions.txt
   ```

## Architecture Options

| Architecture | Description | ABI |
|--------------|-------------|-----|
| rv32i | 32-bit base integer | ilp32 |
| rv64i | 64-bit base integer | lp64 |
| rv32im | 32-bit with multiply/divide | ilp32 |
| rv64im | 64-bit with multiply/divide | lp64 |

## Troubleshooting

### Clang not found
```bash
# Check if clang is installed
which clang
clang --version

# If not found, install it or add to PATH
export PATH="/usr/lib/llvm-15/bin:$PATH"  # Adjust version as needed
```

### Unsupported target
If you get "unsupported target" error, your clang might not have RISC-V support. Try:
```bash
# Check supported targets
clang -print-targets | grep riscv

# If not found, install a newer version of clang/LLVM
```

### Assembly errors
If the assembler fails on clang output, the assembly might use instructions not supported by our processor. Check the generated assembly file with `--keep-asm` flag.

## Integration with Processor

The output `instructions.txt` can be directly used by the Verilog instruction memory:

```verilog
instruction_mem imem (
    .clk(clk),
    .reset(reset),
    .addr(pc_out),
    .instr(instruction)
);
```

## Limitations

1. **No Standard Library**: The processor doesn't have OS support, so standard library functions don't work
2. **Manual Memory Management**: No malloc/free - use static arrays or stack allocation
3. **No I/O**: No printf/scanf - use memory-mapped I/O or return values
4. **Limited Debugging**: Use simulation and waveform viewers for debugging

## Advanced Usage

### Custom Linker Script
For more complex programs, you may need a custom linker script to define memory layout.

### Inline Assembly
You can use inline assembly for direct hardware control:
```c
asm volatile("add x5, x6, x7");
```

### Optimization Levels
- `-O0`: No optimization (easiest to debug)
- `-O1`: Basic optimization
- `-O2`: Standard optimization
- `-O3`: Aggressive optimization
- `-Os`: Optimize for size
