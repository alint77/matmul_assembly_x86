Implementing float32 Matrix Multiplication in X86_64 assembly and attempting to optimise using various techniques.


matmul_scalar_1.asm : Naive implementation on small matrices. 

matmul_scalar_2.asm : Naive implementation on 1024x1024 matrices - ~600ms (experimenting with instruction level parallelism to speedup)  

