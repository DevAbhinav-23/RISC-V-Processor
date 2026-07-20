# RISC-V Processor: Advanced 5-Stage Pipeline

This project implements a high-performance **64-bit RISC-V processor** in Verilog.  
The processor is developed in three progressive stages:

1. **Sequential (Single-Cycle) Processor**
2. **Baseline 5-Stage Pipelined Processor**
3. **Advanced Pipelined Processor** (incorporating all the new features detailed below)

The design supports a robust subset of the **RISC-V ISA** including R-type, I-type, load/store, and branch instructions. For exact instruction encoding and ISA reference, please refer to the provided `RISCV_CARD.pdf`.

The processor datapath and control logic are based on the architecture described in *Computer Organization and Design – RISC-V Edition by Patterson and Hennessy*.

## Beyond the Baseline: Major Architectural Improvements
While the baseline requirements for this project were to build a standard 5-stage pipeline with basic forwarding, load-use hazard stalling, and static "always not-taken" branch prediction resolved in the EX stage, **this implementation goes significantly beyond the baseline.** We have engineered a fully featured, highly optimized processor capable of executing complex programs and function calls.

We have implemented several advanced features that dramatically improve instruction throughput and reduce pipeline stalls compared to the standard requirements:

1. **Dynamic 2-Bit Branch Prediction & BTB:** Instead of a naive static predictor, we implemented a 2-bit saturating counter (Branch History Table) paired with a Branch Target Buffer (BTB). This allows the processor to dynamically learn branch behavior and fetch target addresses immediately in the **IF stage**.
2. **Early Branch Resolution:** We moved branch resolution from the EX stage up to the **ID stage**. This reduces the branch misprediction penalty from multiple cycles down to a **single flush cycle**.
3. **Advanced Hazard Resolution:** Beyond standard EX hazard forwarding, we implemented:
   - **Branch Forwarding Unit:** Custom forwarding paths specifically to resolve data dependencies for the early branch resolution in the ID stage.
   - **Load-Store Forwarding Unit:** An extra forwarding unit to bypass data directly from loads to store instructions, preventing stalls when a load is immediately followed by a store.
4. **Comprehensive ISA Support:** The processor supports a robust subset of the RISC-V ISA, meaning it can act as a fully functional processor capable of complex function calls and returns. Supported instructions include:
   - Full **R-type** and **I-type** arithmetic instructions.
   - Full **B-type** conditional branches (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`).
   - Full **J-type** and I-type jumps (`jal`, `jalr`).
   - Complete memory access operations (`ld`, `sd`).
5. **Hardware Multiplication (M-Extension partially implemented):** We implemented a Radix-4 Booth-Encoded Wallace Tree multiplier for highly efficient single-cycle multiplication operations.

---

# Salient Features

- Designed and implementated of a **64-bit RISC-V processor** with both **single-cycle and 5-stage pipelined architectures (IF, ID, EX, MEM, WB)** supporting R-type, I-type, `ld`, `sd`, and `beq` instructions in verilog.
- Individually implemented the **core datapath modules**, **hazard detection unit**, and **forwarding logic** to resolve data hazards and reduce pipeline stalls.
- **Branch resolution moved to the ID stage**, reducing branch misprediction penalty to a **single pipeline flush cycle** using a static always-not-taken predictor.
- Developed **Verilog testbenches** to verify pipeline execution, hazard handling, and memory operations.

---

# Architecture Overview

## Sequential Processor

In the **single-cycle architecture**, every instruction completes all stages of execution in a single clock cycle.

Stages executed within the cycle:

1. Instruction Fetch
2. Instruction Decode
3. Execute
4. Memory Access
5. Write Back

Advantages:
- Simple design
- Easier verification

Limitations:
- Long critical path
- Lower performance

---

## Pipelined Processor

The pipelined processor divides instruction execution into **five stages**:

| Stage | Description |
|------|-------------|
| IF | Instruction Fetch |
| ID | Instruction Decode |
| EX | Execute |
| MEM | Memory Access |
| WB | Write Back |

Multiple instructions execute simultaneously across stages, improving overall throughput.

### Pipeline Enhancements

The pipeline design includes:

- Hazard Detection Unit
- Forwarding Units
- Branch forwarding logic
- Pipeline registers
- Stall and flush control
- Load-store forwarding unit
- 2-bit branch predictor with BTB-based target prediction

---

# Branch Prediction Unit

The pipelined processor includes a branch prediction mechanism designed to reduce the penalty of control-flow instructions such as conditional branches. Instead of waiting for the branch outcome in the ID stage before fetching the next instruction, the processor predicts the branch direction early in the IF stage and uses a target buffer to anticipate where execution should continue.

## Overview

The predictor consists of two cooperating structures:

1. A 2-bit Branch History Table (BHT)
2. A Branch Target Buffer (BTB)

The BHT is used to predict whether a branch will be taken or not taken, while the BTB stores previously seen branch targets so that the processor can predict the destination address as soon as the branch is encountered again.

## 2-bit Branch History Table (BHT)

The Branch History Table is implemented as a small local predictor with 64 entries. Each entry stores a 2-bit saturating counter that represents the recent history of a branch instruction at a given program counter index.

### Structure

- Number of entries: 64
- Entry width: 2 bits
- Indexing: derived from the branch instruction address using bits `PC[7:2]`
- Initial state: `01`, which represents a weakly not-taken prediction

### Prediction Rule

The predictor uses the most significant bit of the 2-bit state to decide if the branch is predicted taken:

- `00` → not taken
- `01` → not taken (weakly not taken)
- `10` → taken (weakly taken)
- `11` → taken (strongly taken)

This is a classic 2-bit saturating counter design. It is less sensitive to single mispredictions than a 1-bit predictor because it requires a branch to be wrong multiple times before changing its confidence dramatically.

### Update Rule

When a branch instruction reaches the ID stage and its actual outcome becomes known, the predictor updates the state for the corresponding branch entry:

- If the branch is taken, the state moves toward the taken side
- If the branch is not taken, the state moves toward the not-taken side
- The state is updated in a saturating way so it cannot move beyond the two extreme states

This makes the predictor more stable and prevents it from oscillating too quickly for branches whose behavior is not perfectly regular.

## Branch Target Buffer (BTB)

The Branch Target Buffer is used to predict the branch target address. It stores the target address for previously seen branches and allows the processor to redirect the PC early when a branch is predicted to be taken.

### Structure

- Number of entries: 64
- Each entry stores:
  - a valid bit
  - a tag derived from the upper part of the PC
  - the predicted target address

### Lookup

The BTB lookup uses the same PC index as the BHT (`PC[7:2]`). If the tag matches and the entry is valid, the BTB signals a hit and provides the predicted target address.

### Update

When a branch is resolved, the BTB entry for the branch PC is updated with the resolved target address. This allows future executions of the same branch to jump directly to the target without waiting for the branch to be resolved again.

## Integration with the Pipeline

The predictor is integrated into the pipeline in the following way:

- During IF, the processor consults the predictor and BTB using the current PC
- If the branch is predicted taken and the BTB hit is valid, the next PC is set to the predicted target
- The actual branch outcome is resolved later in ID using the branch comparison logic
- If the prediction was wrong, the pipeline flushes the incorrectly fetched instruction stream and recovers by redirecting execution to the correct path

This design reduces the branch penalty by allowing the processor to continue fetching along the predicted path instead of stalling immediately after a branch is encountered.

## Behavioral Effect

The branch predictor improves overall pipeline efficiency by:

- reducing stalls caused by unresolved branches
- allowing earlier target-address selection
- lowering the average cost of branch instructions
- supporting better throughput for branch-heavy code

Although this is a relatively simple predictor compared with modern superscalar designs, it provides a practical and effective mechanism for improving the performance of the pipelined RISC-V processor without introducing excessive hardware complexity.

---

# Processor Modules

---

# Arithmetic Logic Unit (ALU)

The **ALU** performs arithmetic and logical operations on two **64-bit operands** according to the control signals generated by the ALU Control unit.

The ALU result is used for:

- arithmetic operations
- memory address calculation
- branch comparisons

### Inputs

| Signal | Width | Description |
|------|------|-------------|
| Operand A | 64 | First operand from register file |
| Operand B | 64 | Second operand from register file or immediate |
| ALU Control | 4 | Operation selector |

### Outputs

| Signal | Width | Description |
|------|------|-------------|
| ALU Result | 64 | Result of operation |
| Zero Flag | 1 | Indicates if result equals zero |

### Supported Operations

ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, MUL

### Design Optimization

The ALU uses **a single shared 64-bit adder** instead of multiple adders to reduce hardware complexity.

### Zero Flag

The `zero_flag` is generated using a **NOR reduction of the result bus** and is used for branch instructions such as `BEQ`.

---

# Control Unit

The **Control Unit** decodes the instruction opcode and generates control signals that guide datapath components such as the ALU, register file, memory, and multiplexers.

---

# ALU Control

The **ALU Control module** determines the exact ALU operation based on:

- `ALUOp` (2-bit) from the main control unit
- `instr` (5-bit) from the instruction's funct fields

### Why 5-bit Input Instead of 4-bit or 3-bit?

The ALU Control input `instr` is encoded as `{funct7[5], funct7[0], funct3[2:0]}` -- a **5-bit** field.

In the original design (without MUL), 4 bits were sufficient: `{funct7[5], funct3[2:0]}`. This could distinguish ADD vs SUB since they differ in `funct7[5]` (bit 30).

However, ADD, SUB, and MUL all share the **same funct3 = 000**:

| Operation | funct7[5] (bit 30) | funct7[0] (bit 25) | 4-bit encoding | 5-bit encoding |
|-----------|---------------------|---------------------|----------------|----------------|
| ADD       | 0                   | 0                   | `0000`         | `00_000`        |
| SUB       | 1                   | 0                   | `1000`         | `10_000`        |
| MUL       | 0                   | 1                   | `0000`         | `01_000`        |

With only 4 bits, ADD and MUL map to the **same encoding** (`0000`), making them indistinguishable. The 5th bit (`funct7[0]`, instruction bit 25) breaks the tie -- ADD has `funct7[0] = 0` while MUL has `funct7[0] = 1`.

A 3-bit input (funct3 only) would be even worse -- all three operations would collapse to `000`.

Thus, **5 bits is the minimum width required** to uniquely identify ADD, SUB, and MUL.

---

# Register File

The **Register File** contains **32 general purpose registers (x0 – x31)**.

Features:

- Two simultaneous reads
- One write per clock cycle
- Register `x0` always returns zero

---

# Immediate Generator (ImmGen)

The **Immediate Generator** extracts immediate values from instructions and **sign-extends them to 64 bits** for use in arithmetic operations.

---

# Program Counter (PC)

The **Program Counter** stores the address of the next instruction to fetch.

- Normally increments by **4**
- Updated with **branch target address** for branch instructions

---

# Instruction Memory

Instruction memory stores the program instructions.

Features:

- 4096 byte memory
- Byte-addressable
- Instructions loaded from `instructions.txt`

---

# Data Memory

Data memory stores runtime data used by load and store instructions.

Features:

- Byte-addressable memory
- Supports both **read and write operations**

---

# Multiplexers (MUX)

Multiplexers select between different datapath inputs such as:

- register values
- immediate values
- ALU outputs
- memory outputs

---

# Pipeline Registers

Pipeline registers separate the pipeline stages and store intermediate results between clock cycles.

| Register | Between Stages |
|---------|---------------|
| IF/ID | Instruction Fetch → Decode |
| ID/EX | Decode → Execute |
| EX/MEM | Execute → Memory |
| MEM/WB | Memory → Write Back |

---

# Hazard Detection Unit

The **Hazard Detection Unit** detects situations where an instruction depends on data that has not yet been produced.

When a hazard is detected:

- PC is frozen
- IF/ID pipeline register is frozen
- A **NOP bubble** is inserted

---

# Forwarding Unit

The **Forwarding Unit** resolves **Read-After-Write (RAW) hazards** by forwarding results from later pipeline stages directly to the ALU inputs.

This reduces pipeline stalls.

---

# Branch Forwarding Unit

The **Branch Forwarding Unit** forwards updated register values to the branch comparison logic in the **ID stage**, allowing branches to be resolved earlier.

---

# Multiplication (MUL) Unit

The processor supports the **RISC-V M-extension MUL instruction** (32x32 signed multiply, lower 64 bits of result).

### Implementation

The multiplier uses a **Radix-4 Booth-Encoded Wallace Tree** algorithm:

1. **Booth Encoding** -- The 32-bit multiplier (B) is recoded into 17 signed digits in the set {-2, -1, 0, +1, +2} using radix-4 Booth recoding. This halves the number of partial products compared to a straightforward array multiplier.

2. **Partial Product Generation** -- For each Booth digit, a partial product is generated as `digit * A`, then sign-extended and left-shifted by the appropriate amount.

3. **Wallace Tree Summation** -- All 17 partial products are summed. Synthesis tools infer an optimal Carry-Save Adder (CSA) tree for parallel compression, reducing the critical path.

4. **Result** -- The lower 64 bits of the final sum form the multiplication result.

### Modules

| Module | Description |
|--------|-------------|
| `booth_encoder` | Recodes 3-bit groups into Booth digits (sign + 2-bit encode) |
| `booth_wallace_multiplier` | Top-level multiplier: Booth encoding, partial product generation, and summation |

### Integration

The multiplier is instantiated inside the ALU as `inst7` and selected when the ALU opcode is `MUL_Oper (4'b1001)`. The ALU Control module generates this opcode when `ALUOp = 2'b10` (R-type) and the instruction's funct fields match MUL encoding.

---

# Load-Store Forwarding Unit

The **Extra Forwarding Unit** handles hazards between **load and store instructions** by forwarding the loaded value directly to the store operation.

---

# Stall and Flush Control

Two control signals ensure correct pipeline execution:

**Stall**
- Freezes early pipeline stages when data is not ready.

**Flush**
- Removes incorrectly fetched instructions when a branch is taken.

---


# Jump and Branch Instructions

The processor fully supports comprehensive control flow instructions, including all conditional branches and unconditional jumps.

### Conditional Branches (B-Type)
The pipeline supports the full suite of RISC-V conditional branches: `beq`, `bne`, `blt`, `bge`, `bltu`, and `bgeu`.
- **Early Branch Resolution:** Branch comparison is performed in the **ID stage** rather than the EX stage. This is supported by a dedicated branch forwarding unit to resolve data hazards early, minimizing the branch misprediction penalty to a single flush cycle.
- **Comparisons:** The comparator performs full 64-bit evaluations. For unsigned branches (`bltu`, `bgeu`), the operands are treated as unsigned 64-bit integers directly without the need for manual zero-extension.

### Unconditional Jumps (J-Type and I-Type)
- **`jal` (Jump and Link):** Calculates the jump target as a PC-relative offset. The return address (PC + 4) is reliably saved to the destination register (`rd`).
- **`jalr` (Jump and Link Register):** Calculates the jump target based on a base register (`rs1`) plus an immediate offset. In this architecture, it is specially optimized to save instruction encoding space (see Immediate Generation below).

---

# Immediate Generation and Encoding

The immediate generator (`immgen`) extracts immediate values from the 32-bit instruction and sign-extends them to 64 bits. The encoding and decoding of these immediates vary significantly based on the instruction type to maximize efficiency and maintain compatibility:

### Memory Access (`ld`, `sd`) and Standard I-Type
For load (`ld`) and store (`sd`) instructions, the immediate represents a pure memory byte offset from a base register.
- **Encoding:** The exact byte offset is stored verbatim in the immediate fields by the assembler.
- **Decoding:** The processor extracts and sign-extends the value without any shifting. It is added directly to the base register to compute the exact byte address for Data Memory.

### JAL and B-Type Branches
Jump (`jal`) and conditional branch instructions target instruction addresses. To remain compatible with the RISC-V "C" (Compressed) Extension, these jumps are always aligned to multiples of 2 bytes.
- **Encoding:** To save an extra bit of space, the assembler drops the least significant bit (bit 0) of the target byte offset. For example, if you want to jump 16 bytes (4 instructions), you write `16` in assembly, but the assembler stores `8`.
- **Decoding:** When `immgen` decodes the instruction, it implicitly shifts the value left by 1 (by appending a `1'b0` at the lowest bit position), instantly scaling the stored `8` back up to `16` before calculating the target PC.

### JALR Optimization
Although `jalr` is technically an I-type instruction, this implementation employs a custom space-saving optimization that mimics standard branch instructions.
- **Encoding:** The custom assembler shifts the target byte offset right by 1 before storing it (e.g., storing `8` instead of `16`). This effectively doubles the maximum jump reach of the 12-bit immediate field from ±2048 bytes to ±4096 bytes.
- **Decoding:** In the processor, rather than appending a bit inside `immgen.v`, the pipeline wrapper explicitly shifts the immediate left by 1 (`immgen_out << 1`) during the `jalr_target` address calculation to recover the original byte offset.

---

# Testing

To test the processor implementation, follow these steps:

1. **Download the repository** and ensure the folder structure is preserved (both `SEQ` and `Pipeline` folders should remain intact).

2. Write your program in **RISC-V assembly**.

3. Use the provided **assembler** to convert the assembly program into **big-endian hexadecimal instruction format**.

4. Copy the generated instruction bytes and paste them into the file **instructions.txt** 
located in the respective implementation folder (`SEQ` or `Pipeline`).

5. Run the corresponding **testbench file** using your Verilog simulator.

Sequential processor:
seq_tb.v

Pipelined processor:
pipe_tb.v


The simulator will execute the instructions and display the register and pipeline outputs, allowing verification of correct processor behavior.


---



# Detailed Documentation

For a detailed explanation of the **sequential processor design** and **pipelined processor implementation**, please refer to the reports present in the respective folders:

- `SEQ/Sequential_Report.pdf`
- `Pipeline/RISC_V_Processor_Pipeline_Report.pdf`

---

# Future Plans

To further enhance the capabilities of this processor, the following features are planned for future development:
1. **Full M-Extension Implementation:** Expanding the current multiplication support to include full division (`div`, `divu`) and modulo (`rem`, `remu`) operations.
2. **Floating Point Unit (F-Extension):** Integrating a dedicated Floating Point Unit (FPU) to process single-precision floating-point arithmetic, allowing the processor to handle complex scientific and graphical computations.
