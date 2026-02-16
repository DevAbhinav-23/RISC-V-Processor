#!/usr/bin/env python3
"""
RISC-V C Compiler using LLVM/Clang
Compiles C code to RISC-V assembly, then to binary machine code

Usage: python c_compiler.py <input.c> [output.txt]
If output is not specified, defaults to instructions.txt

Requirements: clang/llvm must be installed with RISC-V target support
"""

import sys
import os
import subprocess
import tempfile
import argparse

def check_clang():
    """Check if clang is installed"""
    try:
        result = subprocess.run(['clang', '--version'], 
                              capture_output=True, text=True, timeout=5)
        return result.returncode == 0
    except (subprocess.SubprocessError, FileNotFoundError):
        return False

def get_clang_targets():
    """Get list of supported targets from clang"""
    try:
        result = subprocess.run(['clang', '-print-targets'], 
                              capture_output=True, text=True, timeout=5)
        return result.stdout
    except:
        return "Could not get targets"

def compile_c_to_asm(c_file, asm_file, arch='rv64i', abi='lp64', opt_level='-O0'):
    """
    Compile C code to RISC-V assembly using clang
    
    Args:
        c_file: Input C file
        asm_file: Output assembly file
        arch: RISC-V architecture (rv32i, rv64i, etc.)
        abi: ABI (ilp32, lp64, etc.)
        opt_level: Optimization level (-O0, -O1, -O2, -O3, -Os)
    """
    # Determine target based on architecture
    if arch.startswith('rv32'):
        target = 'riscv32-unknown-elf'
        mabi = f'-mabi={abi}' if abi else '-mabi=ilp32'
    else:
        target = 'riscv64-unknown-elf'
        mabi = f'-mabi={abi}' if abi else '-mabi=lp64'
    
    cmd = [
        'clang',
        '--target=' + target,
        '-march=' + arch,
        mabi,
        opt_level,
        '-S',  # Generate assembly only
        '-o', asm_file,
        c_file,
        '-nostdlib',  # Don't link standard library
        '-fno-builtin',  # Don't use built-in functions
        '-ffreestanding',  # Freestanding environment
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print(f"Clang compilation failed:")
            print(f"stdout: {result.stdout}")
            print(f"stderr: {result.stderr}")
            return False
        return True
    except subprocess.TimeoutExpired:
        print("Clang compilation timed out")
        return False
    except Exception as e:
        print(f"Error running clang: {e}")
        return False

def process_asm_for_simple_riscv(asm_file, output_asm_file):
    """
    Process clang-generated assembly to work with our simple RISC-V processor
    
    Clang generates assembly with:
    - Directives (.text, .globl, etc.)
    - Pseudo-instructions
    - ABI register names
    
    We need to:
    - Remove directives
    - Convert to our assembler's syntax
    - Keep only actual instructions
    """
    with open(asm_file, 'r') as f:
        lines = f.readlines()
    
    processed_lines = []
    
    for line in lines:
        original = line.strip()
        
        # Skip empty lines and comments
        if not original or original.startswith('#'):
            continue
        
        # Skip assembler directives (lines starting with .)
        if original.startswith('.'):
            continue
        
        # Skip labels for now (we'll handle them)
        if original.endswith(':'):
            processed_lines.append(original)
            continue
        
        # Skip lines that are not instructions
        # Instructions typically contain a space or tab
        if ' ' not in original and '\t' not in original:
            continue
        
        # Process the instruction
        # Convert ABI register names to x names if needed
        # Our assembler supports both, so this is optional
        
        processed_lines.append(original)
    
    with open(output_asm_file, 'w') as f:
        f.write('\n'.join(processed_lines))
    
    return True

def run_assembler(asm_file, output_file):
    """Run our RISC-V assembler"""
    assembler_path = os.path.join(os.path.dirname(__file__), 'assembler.py')
    
    cmd = [sys.executable, assembler_path, asm_file, output_file]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print(f"Assembler failed:")
            print(f"stdout: {result.stdout}")
            print(f"stderr: {result.stderr}")
            return False
        print(result.stdout)
        return True
    except Exception as e:
        print(f"Error running assembler: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='RISC-V C Compiler using LLVM/Clang',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python c_compiler.py program.c instructions.txt
  python c_compiler.py -O2 program.c
  python c_compiler.py -march=rv32i program.c
        """
    )
    
    parser.add_argument('input', help='Input C file')
    parser.add_argument('output', nargs='?', default='instructions.txt',
                       help='Output file (default: instructions.txt)')
    parser.add_argument('-march', default='rv64i',
                       help='RISC-V architecture (default: rv64i)')
    parser.add_argument('-mabi', default='',
                       help='RISC-V ABI (ilp32, lp64, etc.)')
    parser.add_argument('-O', dest='opt', default='0',
                       help='Optimization level 0/1/2/3/s (default: 0)')
    parser.add_argument('--keep-asm', action='store_true',
                       help='Keep intermediate assembly file')
    parser.add_argument('--check', action='store_true',
                       help='Check if clang is available')
    
    args = parser.parse_args()
    
    # Check mode
    if args.check:
        if check_clang():
            print("✓ Clang is installed")
            print("\nSupported targets:")
            print(get_clang_targets())
        else:
            print("✗ Clang not found. Please install LLVM/Clang with RISC-V support.")
            print("\nInstallation:")
            print("  Ubuntu/Debian: sudo apt-get install clang lld llvm")
            print("  macOS: brew install llvm")
            print("  Or build from source: https://llvm.org/docs/GettingStarted.html")
        return 0
    
    # Check clang is available
    if not check_clang():
        print("Error: clang not found. Please install LLVM/Clang.")
        print("Run with --check for more information.")
        return 1
    
    # Check input file exists
    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found")
        return 1
    
    # Create temporary files
    temp_dir = tempfile.mkdtemp()
    raw_asm = os.path.join(temp_dir, 'raw.s')
    processed_asm = os.path.join(temp_dir, 'processed.s')
    
    try:
        print(f"Compiling {args.input}...")
        print(f"Architecture: {args.march}")
        print(f"Optimization: -O{args.opt}")
        
        # Step 1: Compile C to assembly using clang
        opt_flag = f'-O{args.opt}'
        if not compile_c_to_asm(args.input, raw_asm, args.march, args.mabi, opt_flag):
            print("Compilation failed!")
            return 1
        
        print(f"✓ Generated assembly: {raw_asm}")
        
        # Step 2: Process assembly for our simple processor
        if not process_asm_for_simple_riscv(raw_asm, processed_asm):
            print("Assembly processing failed!")
            return 1
        
        print(f"✓ Processed assembly: {processed_asm}")
        
        # Show the processed assembly
        print("\n--- Generated Assembly ---")
        with open(processed_asm, 'r') as f:
            print(f.read())
        print("--- End Assembly ---\n")
        
        # Step 3: Assemble to binary
        if not run_assembler(processed_asm, args.output):
            print("Assembly failed!")
            return 1
        
        print(f"✓ Output written to: {args.output}")
        
        # Keep assembly if requested
        if args.keep_asm:
            asm_output = args.output.replace('.txt', '.s')
            with open(processed_asm, 'r') as src:
                with open(asm_output, 'w') as dst:
                    dst.write(src.read())
            print(f"✓ Assembly saved to: {asm_output}")
        
        return 0
        
    finally:
        # Cleanup temporary files
        if not args.keep_asm:
            import shutil
            shutil.rmtree(temp_dir, ignore_errors=True)

if __name__ == '__main__':
    sys.exit(main())
