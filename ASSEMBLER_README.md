# RISC-V Assembler

A Python-based assembler for RISC-V RV32I instructions that converts assembly code to binary machine code compatible with the instruction memory module.

## Usage

```bash
python assembler.py <input.asm> [output.txt]
```

If output file is not specified, it defaults to `instructions.txt` (the format expected by the Verilog testbench).

## Example

```bash
python assembler.py example.asm instructions.txt
```

## Supported Instructions

### R-Type (Register-Register)
- `add rd, rs1, rs2` - Add
- `sub rd, rs1, rs2` - Subtract
- `and rd, rs1, rs2` - AND
- `or rd, rs1, rs2` - OR
- `xor rd, rs1, rs2` - XOR
- `sll rd, rs1, rs2` - Shift Left Logical
- `srl rd, rs1, rs2` - Shift Right Logical
- `sra rd, rs1, rs2` - Shift Right Arithmetic
- `slt rd, rs1, rs2` - Set Less Than
- `sltu rd, rs1, rs2` - Set Less Than Unsigned

### I-Type (Immediate)
- `addi rd, rs1, imm` - Add Immediate
- `andi rd, rs1, imm` - AND Immediate
- `ori rd, rs1, imm` - OR Immediate
- `xori rd, rs1, imm` - XOR Immediate
- `slli rd, rs1, shamt` - Shift Left Logical Immediate
- `srli rd, rs1, shamt` - Shift Right Logical Immediate
- `srai rd, rs1, shamt` - Shift Right Arithmetic Immediate
- `slti rd, rs1, imm` - Set Less Than Immediate
- `sltiu rd, rs1, imm` - Set Less Than Immediate Unsigned

### Load Instructions
- `lb rd, offset(rs1)` - Load Byte
- `lh rd, offset(rs1)` - Load Halfword
- `lw rd, offset(rs1)` - Load Word
- `lbu rd, offset(rs1)` - Load Byte Unsigned
- `lhu rd, offset(rs1)` - Load Halfword Unsigned

### Store Instructions
- `sb rs2, offset(rs1)` - Store Byte
- `sh rs2, offset(rs1)` - Store Halfword
- `sw rs2, offset(rs1)` - Store Word

### Branch Instructions
- `beq rs1, rs2, label/offset` - Branch if Equal
- `bne rs1, rs2, label/offset` - Branch if Not Equal
- `blt rs1, rs2, label/offset` - Branch if Less Than
- `bge rs1, rs2, label/offset` - Branch if Greater or Equal
- `bltu rs1, rs2, label/offset` - Branch if Less Than Unsigned
- `bgeu rs1, rs2, label/offset` - Branch if Greater or Equal Unsigned

### Jump Instructions
- `jal rd, label/offset` - Jump and Link
- `jalr rd, offset(rs1)` - Jump and Link Register

### U-Type Instructions
- `lui rd, imm` - Load Upper Immediate
- `auipc rd, imm` - Add Upper Immediate to PC

### Pseudo Instructions
- `nop` - No operation (addi x0, x0, 0)
- `mv rd, rs` - Move (addi rd, rs, 0)
- `li rd, imm` - Load immediate (addi rd, x0, imm)
- `j label/offset` - Jump (jal x0, label/offset)
- `jr rs` - Jump register (jalr x0, rs, 0)
- `ret` - Return (jalr x0, x1, 0)
- `seqz rd, rs` - Set if equal to zero (sltiu rd, rs, 1)
- `snez rd, rs` - Set if not equal to zero (sltu rd, x0, rs)
- `not rd, rs` - NOT (xori rd, rs, -1)
- `neg rd, rs` - Negate (sub rd, x0, rs)

## Syntax

### Registers
- Numbered: `x0` to `x31`
- ABI names: `zero`, `ra`, `sp`, `gp`, `tp`, `t0`-`t6`, `s0`-`s11`, `a0`-`a7`, `fp`

### Immediate Values
- Decimal: `10`, `-5`
- Hexadecimal: `0xFF`, `0xABC`
- Binary: `0b1010`

### Labels
```asm
loop:
    add x5, x5, x6
    beq x5, x10, loop
```

### Comments
Use `#` for comments:
```asm
# This is a comment
add x5, x6, x7  # This is also a comment
```

## Example Assembly Programs

### Example 1: Simple Arithmetic
```asm
# Load immediate values
li x5, 10       # x5 = 10
li x6, 20       # x6 = 20

# Arithmetic operations
add x7, x5, x6  # x7 = x5 + x6 = 30
sub x8, x6, x5  # x8 = x6 - x5 = 10
and x9, x7, x8  # x9 = x7 & x8
or x10, x7, x8  # x10 = x7 | x8
```

### Example 2: Loop
```asm
# Initialize
li x5, 0        # counter
li x6, 10       # limit

loop:
    addi x5, x5, 1      # increment counter
    blt x5, x6, loop    # if counter < limit, continue loop
```

### Example 3: Memory Operations
```asm
# Store values
li x5, 100
li x6, 200
sw x5, 0(x0)    # store x5 at address 0
sw x6, 4(x0)    # store x6 at address 4

# Load values
lw x7, 0(x0)    # load from address 0 into x7
lw x8, 4(x0)    # load from address 4 into x8
add x9, x7, x8  # add loaded values
```

## Output Format

The assembler generates output in the format expected by the Verilog instruction memory:
- One byte per line in hexadecimal
- Little-endian byte order (matching the processor's memory layout)

Example output for instruction `0x00500113` (addi x2, x0, 5):
```
13
01
50
00
```

## Notes

- The assembler performs two-pass assembly to handle labels and forward references
- Immediate values are checked for valid ranges
- Branch and jump targets are calculated as PC-relative offsets
- The assembler follows standard RISC-V assembly syntax
