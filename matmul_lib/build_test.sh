#!/bin/bash

# Compile assembly code
nasm -f elf64 matmul_simd_10_lib.asm -o matmul_simd_10_lib.o

# Compile C test programs
clang -O2 -march=native -c test_matmul_lib.c -o test_matmul_lib.o
clang -O2 -march=native -c test_matmul_lib_parallel.c -o test_matmul_lib_parallel.o

# Link everything together
gcc -z noexecstack -o test_matmul.out test_matmul_lib.o matmul_simd_10_lib.o
gcc -z noexecstack -o test_matmul_parallel.out test_matmul_lib_parallel.o matmul_simd_10_lib.o -lpthread

# Make executables
chmod +x test_matmul.out
chmod +x test_matmul_parallel.out

echo "Build complete. Run:"
echo "  ./test_matmul.out for single-threaded test"
