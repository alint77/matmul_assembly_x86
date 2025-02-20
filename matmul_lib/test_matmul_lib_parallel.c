#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include "matmul_simd_10_lib.h"

#define NUM_THREADS 12

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

// Structure to hold thread arguments
typedef struct {
    float* A;
    float* B_blocked;
    float* C;
    int start_row;
    int num_rows;
    int a_cols;
    int b_cols;
} ThreadArgs;

// Thread function for parallel matrix multiplication
void* thread_matmul(void* arg) {
    ThreadArgs* args = (ThreadArgs*)arg;
    
    // Calculate pointer to this thread's portion of A
    float* A_start = args->A + (args->start_row * args->a_cols);
    float* C_start = args->C + (args->start_row * args->b_cols);
    
    // Call SIMD matrix multiply on this portion
    matrix_multiply_simd(A_start, args->B_blocked, C_start, 
                        args->num_rows, args->a_cols, args->b_cols);
    
    return NULL;
}

int main() {
    // Use larger matrices for better performance measurement
    const int A_ROWS = 1152;  // Must be multiple of 6 for our kernel
    const int A_COLS = 1152;  // Must be multiple of 16 for SIMD
    const int B_COLS = 1152;  // Must be multiple of 16 for SIMD

    printf("Initializing parallel test with %dx%d matrices using %d threads...\n", 
           A_ROWS, A_COLS, NUM_THREADS);
    fflush(stdout);

    // Allocate aligned memory for matrices
    float* A = aligned_alloc(32, A_ROWS * A_COLS * sizeof(float));
    float* B = aligned_alloc(32, A_COLS * B_COLS * sizeof(float));
    float* B_blocked = aligned_alloc(32, A_COLS * B_COLS * sizeof(float));
    float* C = aligned_alloc(32, A_ROWS * B_COLS * sizeof(float));
    float* C_test = aligned_alloc(32, A_ROWS * B_COLS * sizeof(float));

    if (!A || !B || !B_blocked || !C || !C_test) {
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
    memset(C_test, 0, A_ROWS * B_COLS * sizeof(float));

    // Convert B to blocked format
    printf("Converting matrix format...\n");
    fflush(stdout);
    convert_to_blocked_format(B, B_blocked, A_COLS, B_COLS);

    // Calculate reference result
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            for (int k = 0; k < A_COLS; k++) {
                C_test[i * B_COLS + j] += A[i * A_COLS + k] * B[k * B_COLS + j];
            }
        }
    }

    printf("Starting parallel matrix multiplication...\n");
    fflush(stdout);

    // Create thread arguments and pthread handles
    pthread_t threads[NUM_THREADS];
    ThreadArgs thread_args[NUM_THREADS];
    
    // Calculate rows per thread (must be multiple of 6)
    int base_rows_per_thread = (A_ROWS / NUM_THREADS / 6) * 6;
    
    for (int iter = 0; iter < 1000; iter++) {
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);

        // Launch threads
        int current_row = 0;
        for (int t = 0; t < NUM_THREADS; t++) {
            // Calculate number of rows for this thread
            int rows_this_thread = base_rows_per_thread;
            if (t == NUM_THREADS - 1) {
                // Last thread gets any remaining rows
                rows_this_thread = A_ROWS - current_row;
            }
            
            // Setup thread arguments
            thread_args[t].A = A;
            thread_args[t].B_blocked = B_blocked;
            thread_args[t].C = C;
            thread_args[t].start_row = current_row;
            thread_args[t].num_rows = rows_this_thread;
            thread_args[t].a_cols = A_COLS;
            thread_args[t].b_cols = B_COLS;
            
            // Create thread
            if (pthread_create(&threads[t], NULL, thread_matmul, &thread_args[t]) != 0) {
                fprintf(stderr, "Failed to create thread %d\n", t);
                return 1;
            }
            
            current_row += rows_this_thread;
        }

        // Wait for all threads to complete
        for (int t = 0; t < NUM_THREADS; t++) {
            pthread_join(threads[t], NULL);
        }

        clock_gettime(CLOCK_MONOTONIC, &end);
        double time_taken = get_time_diff(start, end);

        // Calculate GFLOPs
        double operations = 2.0 * A_ROWS * A_COLS * B_COLS;
        double gflops = (operations / time_taken) * 1e-9;

        printf("Wall time: %.6f seconds - ", time_taken);
        printf("Performance: %.2f GFLOPs\n", gflops);
        fflush(stdout);
    }

    // Verify results
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        if (C[i] != C_test[i]) {
            fprintf(stderr, "Verification failed at index %d! (%.2f != %.2f)\n", 
                    i, C[i], C_test[i]);
            return 1;
        }
    }

    printf("Verification passed!\n");

    // Free memory
    free(A);
    free(B);
    free(B_blocked);
    free(C);
    free(C_test);

    return 0;
}