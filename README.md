# High-Performance Matrix Multiplication in x86_64 Assembly

[![Architecture](https://img.shields.io/badge/Architecture-x86__64-blue)](https://en.wikipedia.org/wiki/X86-64)
[![Performance](https://img.shields.io/badge/Performance-135%20GFLOPs-green)](https://github.com/your-username/matmul_assembly_x86)
[![OpenBLAS](https://img.shields.io/badge/Comparable%20to-OpenBLAS-orange)](https://www.openblas.net/)

A high-performance implementation of float32 matrix multiplication in x86_64 assembly, optimized using various techniques to achieve performance comparable to or exceeding OpenBLAS (~130 GFLOPs).

## Table of Contents
- [System Specifications](#system-specifications)
- [Implementation Evolution](#implementation-evolution)
  - [Scalar Implementations](#scalar-implementations)
  - [SIMD Implementations](#simd-implementations)
- [Library Implementation](#library-implementation)
- [Performance Results](#performance-results)

## System Specifications

- CPU: AMD Ryzen 7 5800x
- Memory: 32GB (4x8GB) DDR4-3600 CL14 with tuned subtimings

## Implementation Evolution

### Scalar Implementations

#### 1. Naive Implementation (`matmul_scalar_1.asm`)
- Initial implementation for small matrices
- Baseline for optimization

#### 2. Large Matrix Implementation (`matmul_scalar_2.asm`)
- Handles 1024x1024 matrices
- Performance: ~2.8s (with high variance)
- Comparison with C:
  - `-O0`: 4.3s
  - `-O3`: 3.4s
- Optimizations:
  - Cached matrix dimensions in registers
  - Aligned instructions (~2.1s)
  - Aligned matrices (~1.85s)

#### 3. Column-Major Format (`matmul_scalar_3.asm`)
- Stores second matrix in column-major format
- Improved cache hit rate
- Performance: ~0.65s

### SIMD Implementations

#### 4. AVX2 Introduction (`matmul_simd_4.asm`)
- Utilizes AVX2 SIMD instructions
- Processes 8 float32 values per instruction
- Inner loop unrolling
- Performance: ~0.085s

#### 5. 2x2 Kernel (`matmul_simd_5.asm`)
- Calculates 4 elements of C per iteration
- Improved memory access efficiency
- Performance: ~0.034s (~62 GFLOPs)

#### 6. 2x4 Kernel (`matmul_simd_6.asm`)
- Expanded kernel to 2x4 submatrix
- 6 memory reads for 8 C elements
- Performance: ~0.0255s (~84 GFLOPs)

#### 7. 3x4 Kernel (`matmul_simd_7.asm`)
- Optimal register utilization
- All 16 vector FP registers (ymm) utilized
- Performance: ~0.0205s (~105 GFLOPs)

#### 8. Block Storage (`matmul_simd_8.asm`)
- Matrices stored in blocks
- Sequential memory reads
- Performance: ~0.0183s (~118 GFLOPs)

#### 9. Algorithm Rewrite (`matmul_simd_9.asm`)
- 6x2(x8) kernel implementation
- Uses `vbroadcastss` on A elements
- Eliminated horizontal add operations

#### 10. Final Optimization (`matmul_simd_10.asm`)
- Optimized blocking order for matrix B
- Performance: ~135 GFLOPs
- C implementation available
  - Outperforms OpenBLAS (~145 GFLOPs)
  - Compile with: `clang -O3 -march=native`

## Library Implementation

The `matmul_lib` directory contains:
- AMD64 SysV ABI compliant implementation
- Linkable library format
- Performance comparable to or exceeding OpenBLAS
- Parallel implementation using `matmul_simd_10.asm`
