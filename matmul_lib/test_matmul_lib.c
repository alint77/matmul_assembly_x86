#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "matmul_simd_10_lib.h"

// Helper function to convert matrix to blocked format for SIMD
void convert_to_blocked_format(float* src, float* dst, int rows, int cols) {
    memset(dst, 0, rows * cols * sizeof(float));
    for (int j = 0; j < cols; j += 16) {
        for (int i = 0; i < rows; i++) {
            for (int jj = 0; jj < 16 && (j + jj) < cols; jj++) {
                dst[j * rows + i * 16 + jj] = src[i * cols + j + jj];
            }
        }
    }
}

double get_time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) * 1e-9;
}

int main() {
    // Use larger matrices for better performance measurement
    const int A_ROWS = 1152;  // Must be multiple of 6 for our kernel
    const int A_COLS = 1152;  // Must be multiple of 16 for SIMD
    const int B_COLS = 1152;  // Must be multiple of 16 for SIMD

    printf("Initializing test with %dx%d matrices...\n", A_ROWS, A_COLS);
    fflush(stdout);

    // Allocate aligned memory for matrices
    float* A = aligned_alloc(32, A_ROWS * A_COLS * sizeof(float));
    float* B = aligned_alloc(32, A_COLS * B_COLS * sizeof(float));
    float* B_blocked = aligned_alloc(32, A_COLS * B_COLS * sizeof(float));
    float* C = aligned_alloc(32, A_ROWS * B_COLS * sizeof(float));
    float* C_test = aligned_alloc(32, A_ROWS * B_COLS * sizeof(float));

    if (!A || !B || !B_blocked || !C) {
        fprintf(stderr, "Memory allocation failed!\n");
        return 1;
    }

    // Initialize matrices with some values
    for (int i = 0; i < A_ROWS * A_COLS; i++) {
        A[i] = (float)(i % 5);
    }
    for (int i = 0; i < A_COLS * B_COLS; i++) {
        B[i] = (float)(i % 3);
    }
    memset(C, 0, A_ROWS * B_COLS * sizeof(float));

    printf("Converting matrix format...\n");
    fflush(stdout);


    for (int i = 0; i < A_ROWS; i++)
    {
        for (int  j = 0; j < B_COLS; j++)
        {
            for (int k = 0; k < A_COLS; k++)
            {
                C_test[i * B_COLS + j] += A[i * A_COLS + k] * B[k * B_COLS + j];
            }
        }
    }
    

    // Convert B to blocked format
    convert_to_blocked_format(B, B_blocked, A_COLS, B_COLS);

    printf("Starting matrix multiplication...\n");
    fflush(stdout);
    for (int i = 0; i < 20; i++)
    {
    
        // Measure wall time
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);

        // Perform multiplication
        float* result = matrix_multiply_simd(A, B_blocked, C, A_ROWS, A_COLS, B_COLS);
        if (!result) {
            fprintf(stderr, "Matrix multiplication failed!\n");
            return 1;
        }

        clock_gettime(CLOCK_MONOTONIC, &end);
        double time_taken = get_time_diff(start, end);

        // Calculate GFLOPs
        // Matrix multiplication requires 2*M*N*K floating point operations
        double operations = 2.0 * A_ROWS * A_COLS * B_COLS;
        double gflops = (operations / time_taken) * 1e-9;

        printf("\nPerformance Results:\n");
        printf("Matrix size: %dx%d * %dx%d\n", A_ROWS, A_COLS, A_COLS, B_COLS);
        printf("Wall time: %.6f seconds\n", time_taken);
        printf("Performance: %.2f GFLOPs\n", gflops);
        fflush(stdout);
    }

    // Verify results
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        if (C[i] != C_test[i]) {
            fprintf(stderr, "Verification failed at index %d!\n", i);
            return 1;
        }
    }

    printf("Verification passed!\n");

    // Free memory
    free(A);
    free(B);
    free(B_blocked);
    free(C);

    return 0;
}