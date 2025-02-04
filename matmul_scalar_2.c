#include <stdio.h>
#include <time.h>

#define ROWS 1024
#define COLS 1024

float a[ROWS][COLS];
float b[COLS][ROWS]; // b is COLS x ROWS
float c[ROWS][ROWS];

int main() {
    // Initialize matrix a with repeating pattern
    float a_values[] = {2.1f, -5.7f, 4.1f, 1.3f};
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            a[i][j] = a_values[(i * COLS + j) % 4];
        }
    }

    // Initialize matrix b with repeating pattern
    float b_values[] = {-3.1f, 4.3f, 1.7f, 3.1f, 2.1f, -5.7f, 4.1f, 1.3f};
    for (int i = 0; i < COLS; i++) {
        for (int j = 0; j < ROWS; j++) {
            b[i][j] = b_values[(i * ROWS + j) % 8];
        }
    }

    // Measure start time
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    // Perform matrix multiplication
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < ROWS; j++) {
            c[i][j] = 0.0f;
            for (int k = 0; k < COLS; k++) {
                c[i][j] += a[i][k] * b[k][j];
            }
        }
    }

    // Measure end time
    clock_gettime(CLOCK_MONOTONIC, &end);

    // Calculate elapsed time in milliseconds
    double seconds = end.tv_sec - start.tv_sec;
    double nanoseconds = end.tv_nsec - start.tv_nsec;
    if (nanoseconds < 0) {
        nanoseconds += 1e9;
        seconds -= 1;
    }
    double total_time = (seconds + nanoseconds / 1e9) * 1000; // Convert to milliseconds

    // Print the result
    printf("Wall time: %.6f ms\n", total_time);

    return 0;
}
