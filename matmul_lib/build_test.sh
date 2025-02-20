#!/bin/bash

# Compile assembly code
nasm -f elf64 matmul_simd_10_lib.asm -o matmul_simd_10_lib.o

# Compile C test program
gcc -O3 -march=native -c test_matmul_lib.c -o test_matmul_lib.o

# Link everything together
gcc -o test_matmul.out test_matmul_lib.o matmul_simd_10_lib.o

# Make executable
chmod +x test_matmul.out

echo "Build complete. Run ./test_matmul.out to test the implementation."
