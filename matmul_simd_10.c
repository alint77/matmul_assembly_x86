#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <immintrin.h>
#include <time.h>
#include <stdint.h>
#include <stdatomic.h>


#define N 1024


#define A_ROWS 48*24
#define A_COLS_B_ROWS 48*24
#define B_COLS 48*24

uint64_t nanos() {
    struct timespec start;
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    return (uint64_t)start.tv_sec*1000000000 + (uint64_t)start.tv_nsec;
}
// #ifdef __AVX2__
#define BLOCK_A 6
#define BLOCK_B 2
#define SIMD 8
void matmul(const float* a,const float* b,float* c){

    for (int i = 0; i < A_ROWS; i+=BLOCK_A)
    {
        for (int j = 0; j < B_COLS; j+=BLOCK_B*SIMD)
        {
            __m256 acc[BLOCK_A][BLOCK_B] = {};
            for (int k = 0; k < A_COLS_B_ROWS; k++) {
                for (int ia = 0; ia < BLOCK_A; ia++) {
                    __m256 temp_a = _mm256_broadcast_ss(&a[(i+ia)*A_COLS_B_ROWS + k]);
                    for (int ib = 0; ib < BLOCK_B; ib++) {
                        // Now b_swizzled access is sequential in memory
                        __m256 temp_b = _mm256_load_ps(&b[((j/SIMD)+ib)*A_COLS_B_ROWS*SIMD + k*SIMD]);
                        acc[ia][ib] = _mm256_fmadd_ps(temp_a, temp_b, acc[ia][ib]);
                    }
                }
            }
            // Store results
            for (int ia = 0; ia < BLOCK_A; ia++) {
                size_t row = i + ia;
                if (row < A_ROWS) {
                    for (int ib = 0; ib < BLOCK_B; ib++) {
                        size_t col = j/SIMD + ib;
                        size_t idx = row * (B_COLS/SIMD) + col;
                        if (idx * SIMD + SIMD <= A_ROWS * B_COLS) {
                            ((__m256*)c)[idx] = acc[ia][ib];
                        }
                    }
                }
            }
            
        }
        
    }
}

// #endif
int main() {

    float* A_row_major = (float*)aligned_alloc(32, A_ROWS*A_COLS_B_ROWS*sizeof(float));
    float* B_row_major = (float*)aligned_alloc(32, A_COLS_B_ROWS*B_COLS*sizeof(float));
    float* C_row_major = (float*)aligned_alloc(32, A_ROWS*B_COLS*sizeof(float));
        // Add after matrix initialization and before matmul:
    float* B_swizzled = (float*)aligned_alloc(32, A_COLS_B_ROWS*B_COLS*sizeof(float));
    
    for(int i = 0; i < A_ROWS*A_COLS_B_ROWS; i++) A_row_major[i] = -2.0f;
    for(int i = 0; i < A_COLS_B_ROWS*B_COLS; i++) B_row_major[i] = 1.0f;

    // Preswizzle B matrix from row major to column-block major
    for (int k = 0; k < A_COLS_B_ROWS; k++) {
        for (int j = 0; j < B_COLS; j += SIMD) {
            for (int js = 0; js < SIMD; js++) {
                // Convert from [k][j] layout to [j/SIMD][k][js] layout
                B_swizzled[(j/SIMD)*A_COLS_B_ROWS*SIMD + k*SIMD + js] = B_row_major[k*B_COLS + j + js];
            }
        }
    }
    // Initialize matrice
    memset(C_row_major, 0, A_ROWS*B_COLS*sizeof(float));


    // preswizzle B matrix :
    // for (int i = 0; i < count; i++)
    // {
    //     /* code */
    // }
    
    for (int i = 0; i < 20; i++)
    {
        uint64_t start = nanos();

        matmul(A_row_major,B_swizzled,C_row_major);

        uint64_t end = nanos();

        double gflop = (2.0*A_ROWS*A_COLS_B_ROWS*B_COLS)*1e-9;
        double s = (end-start)*1e-9;
        printf("%f GFLOPs, %.6f ms\n", gflop/s, s*1e3);
        
    }
    // printf("first element of C: %f\n",C_row_major[0]);
    free(A_row_major);
    free(B_row_major);
    free(C_row_major);
    return 0;
}