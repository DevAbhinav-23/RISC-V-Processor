#!/usr/bin/env python3
"""
RISC-V RV32I Assembler
Converts RISC-V assembly code to binary machine code

Usage: python assembler.py <input.asm> [output.txt]
If output is not specified, defaults to instructions.txt

Supports: R-type, I-type, Load, Store, Branch instructions
"""

import sys
import re
from enum import Enum

# Instruction encodings
class Opcode:
    LUI    = 0b0110111
    AUIPC  = 0b0010111
    JAL    = 0b1101111
    JALR   = 0b1100111
    BRANCH = 0b1100011
    LOAD   = 0b0000011
    STORE  = 0b0100011
    IMM    = 0b0010011
    OP     = 0b0110011

class Funct3:
    # Branch
    BEQ  = 0b000
    BNE  = 0b001
    BLT  = 0b100
    BGE  = 0b101
    BLTU = 0b110
    BGEU = 0b111
    
    # Load/Store
    LB  = 0b000
    LH  = 0b001
    LW  = 0b010
    LBU = 0b100
    LHU = 0b101
    SB  = 0b000
    SH  = 0b001
    SW  = 0b010
    
    # ALU I-type
    ADDI  = 0b000
    SLTI  = 0b010
    SLTIU = 0b011
    XORI  = 0b100
    ORI   = 0b110
    ANDI  = 0b111
    SLLI  = 0b001
    SRLI  = 0b101
    SRAI  = 0b101
    
    # ALU R-type
    ADD  = 0b000
    SUB  = 0b000
    SLL  = 0b001
    SLT  = 0b010
    SLTU = 0b011
    XOR  = 0b100
    SRL  = 0b101
    SRA  = 0b101
    OR   = 0b110
    AND  = 0b111

class Funct7:
    ADD  = 0b0000000
    SUB  = 0b0100000
    SLL  = 0b0000000
    SLT  = 0b0000000
    SLTU = 0b0000000
    XOR  = 0b0000000
    SRL  = 0b0000000
    SRA  = 0b0100000
    OR   = 0b0000000
    AND  = 0b0000000
    SLLI = 0b0000000
    SRLI = 0b0000000
    SRAI = 0b0100000

# Register mapping
REGISTERS = {
    'x0': 0, 'zero': 0,
    'x1': 1, 'ra': 1,
    'x2': 2, 'sp': 2,
    'x3': 3, 'gp': 3,
    'x4': 4, 'tp': 4,
    'x5': 5, 't0': 5,
    'x6': 6, 't1': 6,
    'x7': 7, 't2': 7,
    'x8': 8, 's0': 8, 'fp': 8,
    'x9': 9, 's1': 9,
    'x10': 10, 'a0': 10,
    'x11': 11, 'a1': 11,
    'x12': 12, 'a2': 12,
    'x13': 13, 'a3': 13,
    'x14': 14, 'a4': 14,
    'x15': 15, 'a5': 15,
    'x16': 16, 'a6': 16,
    'x17': 17, 'a7': 17,
    'x18': 18, 's2': 18,
    'x19': 19, 's3': 19,
    'x20': 20, 's4': 20,
    'x21': 21, 's5': 21,
    'x22': 22, 's6': 22,
    'x23': 23, 's7': 23,
    'x24': 24, 's8': 24,
    'x25': 25, 's9': 25,
    'x26': 26, 's10': 26,
    'x27': 27, 's11': 27,
    'x28': 28, 't3': 28,
    'x29': 29, 't4': 29,
    'x30': 30, 't5': 30,
    'x31': 31, 't6': 31,
}

class AssemblerError(Exception):
    pass

def parse_register(reg_str):
    """Parse register name to number"""
    reg_str = reg_str.strip().lower()
    if reg_str in REGISTERS:
        return REGISTERS[reg_str]
    raise AssemblerError(f"Unknown register: {reg_str}")

def parse_immediate(imm_str, bits, signed=True):
    """Parse immediate value"""
    imm_str = imm_str.strip()
    
    # Handle hexadecimal
    if imm_str.startswith('0x') or imm_str.startswith('0X'):
        value = int(imm_str, 16)
    # Handle binary
    elif imm_str.startswith('0b') or imm_str.startswith('0B'):
        value = int(imm_str, 2)
    else:
        value = int(imm_str)
    
    if signed:
        # Check range for signed value
        min_val = -(1 << (bits - 1))
        max_val = (1 << (bits - 1)) - 1
    else:
        # Check range for unsigned value
        min_val = 0
        max_val = (1 << bits) - 1
    
    if value < min_val or value > max_val:
        raise AssemblerError(f"Immediate {value} out of range for {bits}-bit value")
    
    # Convert to unsigned representation
    if signed and value < 0:
        value = value & ((1 << bits) - 1)
    
    return value

def encode_r_type(rd, rs1, rs2, funct3, funct7, opcode):
    """Encode R-type instruction"""
    instr = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

def encode_i_type(rd, rs1, imm, funct3, opcode):
    """Encode I-type instruction"""
    imm = imm & 0xFFF  # 12-bit immediate
    instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

def encode_s_type(rs1, rs2, imm, funct3, opcode):
    """Encode S-type instruction"""
    imm = imm & 0xFFF  # 12-bit immediate
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0 = imm & 0x1F
    instr = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
    return instr

def encode_b_type(rs1, rs2, imm, funct3, opcode):
    """Encode B-type instruction"""
    imm = imm & 0x1FFE  # 13-bit immediate (even, so effectively 12 bits shifted)
    imm_12 = (imm >> 12) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1 = (imm >> 1) & 0xF
    imm_11 = (imm >> 11) & 0x1
    instr = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
    return instr

def encode_u_type(rd, imm, opcode):
    """Encode U-type instruction"""
    imm = imm & 0xFFFFF000  # Upper 20 bits
    instr = imm | (rd << 7) | opcode
    return instr

def encode_j_type(rd, imm, opcode):
    """Encode J-type instruction"""
    imm = imm & 0x1FFFFE  # 21-bit immediate (even, so effectively 20 bits shifted)
    imm_20 = (imm >> 20) & 0x1
    imm_10_1 = (imm >> 1) & 0x3FF
    imm_11 = (imm >> 11) & 0x1
    imm_19_12 = (imm >> 12) & 0xFF
    instr = (imm_20 << 31) | (imm_19_12 << 12) | (imm_11 << 20) | (imm_10_1 << 21) | (rd << 7) | opcode
    return instr

def parse_line(line):
    """Parse a single line of assembly"""
    # Remove comments
    if '#' in line:
        line = line[:line.index('#')]
    
    # Strip whitespace
    line = line.strip()
    
    if not line:
        return None, None
    
    # Check for label
    label = None
    if ':' in line:
        parts = line.split(':', 1)
        label = parts[0].strip()
        line = parts[1].strip() if len(parts) > 1 else ''
    
    if not line:
        return label, None
    
    # Parse instruction
    parts = re.split(r'[\s,]+', line)
    parts = [p for p in parts if p]
    
    if not parts:
        return label, None
    
    return label, parts

def first_pass(lines):
    """First pass: collect labels and their addresses"""
    labels = {}
    address = 0
    
    for line in lines:
        label, parts = parse_line(line)
        
        if label:
            labels[label] = address
        
        if parts:  # There's an instruction
            address += 4  # Each instruction is 4 bytes
    
    return labels

def assemble_instruction(parts, labels, current_addr):
    """Assemble a single instruction"""
    if not parts:
        return None
    
    mnemonic = parts[0].lower()
    
    # R-type instructions
    if mnemonic == 'add':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.ADD, Funct7.ADD, Opcode.OP)
    elif mnemonic == 'sub':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SUB, Funct7.SUB, Opcode.OP)
    elif mnemonic == 'and':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.AND, Funct7.AND, Opcode.OP)
    elif mnemonic == 'or':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.OR, Funct7.OR, Opcode.OP)
    elif mnemonic == 'xor':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.XOR, Funct7.XOR, Opcode.OP)
    elif mnemonic == 'sll':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SLL, Funct7.SLL, Opcode.OP)
    elif mnemonic == 'srl':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SRL, Funct7.SRL, Opcode.OP)
    elif mnemonic == 'sra':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SRA, Funct7.SRA, Opcode.OP)
    elif mnemonic == 'slt':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SLT, Funct7.SLT, Opcode.OP)
    elif mnemonic == 'sltu':
        rd, rs1, rs2 = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
        return encode_r_type(rd, rs1, rs2, Funct3.SLTU, Funct7.SLTU, Opcode.OP)
    
    # I-type immediate instructions
    elif mnemonic == 'addi':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.ADDI, Opcode.IMM)
    elif mnemonic == 'andi':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.ANDI, Opcode.IMM)
    elif mnemonic == 'ori':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.ORI, Opcode.IMM)
    elif mnemonic == 'xori':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.XORI, Opcode.IMM)
    elif mnemonic == 'slli':
        rd, rs1, shamt = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 5, False)
        imm = (Funct7.SLLI << 5) | shamt
        return encode_i_type(rd, rs1, imm, Funct3.SLLI, Opcode.IMM)
    elif mnemonic == 'srli':
        rd, rs1, shamt = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 5, False)
        imm = (Funct7.SRLI << 5) | shamt
        return encode_i_type(rd, rs1, imm, Funct3.SRLI, Opcode.IMM)
    elif mnemonic == 'srai':
        rd, rs1, shamt = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 5, False)
        imm = (Funct7.SRAI << 5) | shamt
        return encode_i_type(rd, rs1, imm, Funct3.SRAI, Opcode.IMM)
    elif mnemonic == 'slti':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.SLTI, Opcode.IMM)
    elif mnemonic == 'sltiu':
        rd, rs1, imm = parse_register(parts[1]), parse_register(parts[2]), parse_immediate(parts[3], 12)
        return encode_i_type(rd, rs1, imm, Funct3.SLTIU, Opcode.IMM)
    
    # Load instructions
    elif mnemonic == 'lb':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, Funct3.LB, Opcode.LOAD)
    elif mnemonic == 'lh':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, Funct3.LH, Opcode.LOAD)
    elif mnemonic == 'lw':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, Funct3.LW, Opcode.LOAD)
    elif mnemonic == 'lbu':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, Funct3.LBU, Opcode.LOAD)
    elif mnemonic == 'lhu':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, Funct3.LHU, Opcode.LOAD)
    
    # Store instructions
    elif mnemonic == 'sb':
        rs2, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_s_type(parse_register(rs1), rs2, imm, Funct3.SB, Opcode.STORE)
    elif mnemonic == 'sh':
        rs2, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_s_type(parse_register(rs1), rs2, imm, Funct3.SH, Opcode.STORE)
    elif mnemonic == 'sw':
        rs2, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_s_type(parse_register(rs1), rs2, imm, Funct3.SW, Opcode.STORE)
    
    # Branch instructions
    elif mnemonic == 'beq':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13)
        return encode_b_type(rs1, rs2, imm, Funct3.BEQ, Opcode.BRANCH)
    elif mnemonic == 'bne':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13)
        return encode_b_type(rs1, rs2, imm, Funct3.BNE, Opcode.BRANCH)
    elif mnemonic == 'blt':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13)
        return encode_b_type(rs1, rs2, imm, Funct3.BLT, Opcode.BRANCH)
    elif mnemonic == 'bge':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13)
        return encode_b_type(rs1, rs2, imm, Funct3.BGE, Opcode.BRANCH)
    elif mnemonic == 'bltu':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13, False)
        return encode_b_type(rs1, rs2, imm, Funct3.BLTU, Opcode.BRANCH)
    elif mnemonic == 'bgeu':
        rs1, rs2 = parse_register(parts[1]), parse_register(parts[2])
        if parts[3] in labels:
            imm = (labels[parts[3]] - current_addr)
        else:
            imm = parse_immediate(parts[3], 13, False)
        return encode_b_type(rs1, rs2, imm, Funct3.BGEU, Opcode.BRANCH)
    
    # Jump instructions
    elif mnemonic == 'jal':
        rd = parse_register(parts[1])
        if parts[2] in labels:
            imm = labels[parts[2]] - current_addr
        else:
            imm = parse_immediate(parts[2], 21)
        return encode_j_type(rd, imm, Opcode.JAL)
    elif mnemonic == 'jalr':
        rd, offset_rs1 = parse_register(parts[1]), parts[2]
        if '(' in offset_rs1:
            offset, rs1 = offset_rs1.split('(')
            rs1 = rs1.rstrip(')')
        else:
            offset, rs1 = '0', offset_rs1
        imm = parse_immediate(offset, 12)
        return encode_i_type(rd, parse_register(rs1), imm, 0b000, Opcode.JALR)
    
    # U-type instructions
    elif mnemonic == 'lui':
        rd, imm = parse_register(parts[1]), parse_immediate(parts[2], 32, False)
        return encode_u_type(rd, imm, Opcode.LUI)
    elif mnemonic == 'auipc':
        rd, imm = parse_register(parts[1]), parse_immediate(parts[2], 32, False)
        return encode_u_type(rd, imm, Opcode.AUIPC)
    
    # Pseudo-instructions
    elif mnemonic == 'nop':
        # addi x0, x0, 0
        return encode_i_type(0, 0, 0, Funct3.ADDI, Opcode.IMM)
    elif mnemonic == 'mv':
        # addi rd, rs, 0
        rd, rs = parse_register(parts[1]), parse_register(parts[2])
        return encode_i_type(rd, rs, 0, Funct3.ADDI, Opcode.IMM)
    elif mnemonic == 'li':
        # lui + addi or just addi depending on immediate size
        rd, imm = parse_register(parts[1]), parse_immediate(parts[2], 32)
        if imm >= -2048 and imm < 2048:
            return encode_i_type(rd, 0, imm, Funct3.ADDI, Opcode.IMM)
        else:
            raise AssemblerError(f"Large immediate not fully supported yet: {imm}")
    elif mnemonic == 'j':
        # jal x0, offset
        if parts[1] in labels:
            imm = labels[parts[1]] - current_addr
        else:
            imm = parse_immediate(parts[1], 21)
        return encode_j_type(0, imm, Opcode.JAL)
    elif mnemonic == 'jr':
        # jalr x0, rs, 0
        rs = parse_register(parts[1])
        return encode_i_type(0, rs, 0, 0b000, Opcode.JALR)
    elif mnemonic == 'ret':
        # jalr x0, x1, 0
        return encode_i_type(0, 1, 0, 0b000, Opcode.JALR)
    elif mnemonic == 'seqz':
        # sltiu rd, rs, 1
        rd, rs = parse_register(parts[1]), parse_register(parts[2])
        return encode_i_type(rd, rs, 1, Funct3.SLTIU, Opcode.IMM)
    elif mnemonic == 'snez':
        # sltu rd, x0, rs
        rd, rs = parse_register(parts[1]), parse_register(parts[2])
        return encode_r_type(rd, 0, rs, Funct3.SLTU, Funct7.SLTU, Opcode.OP)
    elif mnemonic == 'not':
        # xori rd, rs, -1
        rd, rs = parse_register(parts[1]), parse_register(parts[2])
        return encode_i_type(rd, rs, 0xFFF, Funct3.XORI, Opcode.IMM)
    elif mnemonic == 'neg':
        # sub rd, x0, rs
        rd, rs = parse_register(parts[1]), parse_register(parts[2])
        return encode_r_type(rd, 0, rs, Funct3.SUB, Funct7.SUB, Opcode.OP)
    
    else:
        raise AssemblerError(f"Unknown instruction: {mnemonic}")

def assemble(asm_code):
    """Assemble assembly code to machine code"""
    lines = asm_code.split('\n')
    
    # First pass: collect labels
    labels = first_pass(lines)
    
    # Second pass: generate machine code
    instructions = []
    current_addr = 0
    
    for line_num, line in enumerate(lines, 1):
        try:
            label, parts = parse_line(line)
            
            if parts:
                instr = assemble_instruction(parts, labels, current_addr)
                if instr is not None:
                    instructions.append(instr)
                    current_addr += 4
        except AssemblerError as e:
            raise AssemblerError(f"Line {line_num}: {e}")
    
    return instructions

def format_output(instructions, format='hex_bytes'):
    """Format instructions for output"""
    if format == 'hex_bytes':
        # Each byte on a separate line in hex (little-endian)
        lines = []
        for instr in instructions:
            # Little-endian byte order
            lines.append(f"{instr & 0xFF:02X}")
            lines.append(f"{(instr >> 8) & 0xFF:02X}")
            lines.append(f"{(instr >> 16) & 0xFF:02X}")
            lines.append(f"{(instr >> 24) & 0xFF:02X}")
        return '\n'.join(lines)
    elif format == 'hex_words':
        # Each 32-bit word on a separate line
        return '\n'.join(f"{instr:08X}" for instr in instructions)
    elif format == 'binary':
        # Binary representation
        return '\n'.join(f"{instr:032b}" for instr in instructions)
    else:
        raise AssemblerError(f"Unknown output format: {format}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python assembler.py <input.asm> [output.txt]")
        print("If output is not specified, defaults to instructions.txt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'instructions.txt'
    
    try:
        with open(input_file, 'r') as f:
            asm_code = f.read()
        
        instructions = assemble(asm_code)
        output = format_output(instructions, 'hex_bytes')
        
        with open(output_file, 'w') as f:
            f.write(output)
        
        print(f"Assembled {len(instructions)} instructions to {output_file}")
        
        # Also print hex words for debugging
        print("\nHex representation:")
        for i, instr in enumerate(instructions):
            print(f"0x{i*4:04X}: 0x{instr:08X}")
            
    except FileNotFoundError:
        print(f"Error: Could not find input file '{input_file}'")
        sys.exit(1)
    except AssemblerError as e:
        print(f"Assembly error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
