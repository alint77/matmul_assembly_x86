Implementing float32 Matrix Multiplication in X86_64 assembly and attempting to optimise using various techniques. With the hopes of exceeding 130 GFLOPs reached with openblas. 
__________________

PC specs: Ryzen 7 5800x - 4x8 32GB 3600 MT/s CL14 with tuned subtimings
__________________

Matmul_scalar_1.asm : Naive implementation on small matrices. 
__________________

Matmul_scalar_2.asm : Naive implementation on 1024x1024 matrices: ~2.8s (with high run to run variance)

The equivelant C code runs much slower: -O0: 4.3s, -O3: 3.4s 

profiling shows 99.7% of time being spent inside inner loop (.loop_dotprod)

optimisations:

minimise number of memory accesses inside inner loop by caching i*a_matrix_cols, a_matrix_cols and b_matrix_cols inside registers before reaching inner loop.

aligning the instructions inside the inner loop causes massive performance uplift and reduces variance significantly: ~2.1s 

aligning the matrices themselves also improves performance: ~1.85s
__________________

Matmul_scalar_3.asm : Store second matrix in column major format. more uniform memory access pattern on matrix_b increases cache hits, leading to considerable speedup. ~0.65s 
__________________

Matmul_simd_4.asm : using AVX2 simd to calculate 8 float32 value in one instruction. combined with unrolling the innerloop for lower loop boundary checks overhead leads to a massive speed up: ~0.085s
__________________

Matmul_simd_5.asm : using a 2x2 kernel to calculate 4 elements of C in each innerloop iteration (4 mem reads for 4 C elements instead of 2/element) reaching ~0.034s which is ~62GFLOPs 
__________________

Matmul_simd_6.asm : expanding the kernel to 2x4 submatrix. innerloop now iterates over `a[i:i+2)[k]` and `a[j:j+4)[k]`. so 6 mem reads to calcualte 8 elements of c. result is ~0.0255s or ~84GFLOPs
__________________

Matmul_simd_7.asm : expanding the kernel again to 3x4 submatrix. innerloop now iterates over `a[i:i+3)[k]` and `b[j:j+4)[k]`. so 7 mem reads to calcualte 12 elements of c. result is ~0.0205s or ~105GFLOPs. This is the optimal kernel in terms of register utilisation. all 16 vector FP registers (ymm) are being used inside the innerloop.

