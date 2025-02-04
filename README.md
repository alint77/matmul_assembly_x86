Implementing float32 Matrix Multiplication in X86_64 assembly and attempting to optimise using various techniques.

PC specs: Ryzen 7 5800x - 4x8 32GB 3600 MT/s CL14 with tuned subtimings

matmul_scalar_1.asm : Naive implementation on small matrices. 

matmul_scalar_2.asm : Naive implementation on 1024x1024 matrices: ~2.8s (with high run to run variance)

The equivelant C code runs much slower: -O0: 4.3s, -O3: 3.4s 

profiling shows 99.7% time being spent inside inner loop (.loop_dotprod)

optimisations:
minimise number of memory accesses inside inner loop by caching i*a_matrix_cols, a_matrix_cols and b_matrix_cols inside registers before reaching inner loop.
aligning the instructions inside the inner loop causes massive performance uplift and reduces variance significantly: ~2.1s 
aligning the matrices themselves also improves performance: ~1.85s








