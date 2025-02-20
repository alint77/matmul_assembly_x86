#ifndef MATMUL_SIMD_10_LIB_H
#define MATMUL_SIMD_10_LIB_H

#ifdef __cplusplus
extern "C" {
#endif

// Performs matrix multiplication C = A * B using SIMD instructions
// A must be in row-major format
// B must be in blocked format optimized for SIMD
// C will be in row-major format
// Returns pointer to result matrix C
float* matrix_multiply_simd(float* a, float* b, float* c, 
                          long a_rows, long a_cols, long b_cols);

#ifdef __cplusplus
}
#endif

#endif // MATMUL_SIMD_10_LIB_H