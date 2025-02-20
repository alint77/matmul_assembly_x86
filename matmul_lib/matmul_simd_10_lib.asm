section .text
global matrix_multiply_simd

; matrix_multiply_simd(float* a, float* b, float* c, int64_t a_rows, int64_t a_cols, int64_t b_cols)
; Parameters (System V AMD64 ABI):
;   rdi = pointer to matrix A (row-major)
;   rsi = pointer to matrix B (blocked format for SIMD)
;   rdx = pointer to result matrix C (will be row-major)
;   rcx = number of rows in A
;   r8  = number of columns in A (same as rows in B)
;   r9  = number of columns in B
matrix_multiply_simd:
    push rbp
    mov rbp, rsp
    ; Save preserved registers
    push rbx
    push r12
    push r13
    push r14
    push r15
    ; Align stack to 32 bytes for AVX
    and rsp, -32
    sub rsp, 32  ; Reserve shadow space

    ; Validate input parameters
    test rdi, rdi  ; Check if A is null
    jz .error
    test rsi, rsi  ; Check if B is null
    jz .error
    test rdx, rdx  ; Check if C is null
    jz .error
    
    ; Save parameters
    mov r11, rdi        ; r11 = A matrix pointer
    push rsi            ; Save B matrix pointer
    push rdx            ; Save C matrix pointer
    mov r14, rcx        ; r14 = a_rows
    mov r15, r8         ; r15 = a_cols (b_rows)
    mov r13, r9         ; r13 = b_cols

    ; Calculate stride values
    mov rbx, r15
    shl rbx, 2          ; rbx = a_cols * 4 (stride for next row)

    xor r8, r8          ; r8 = i = 0 (row counter)
.loop_a_rows:
    xor r9, r9          ; r9 = j = 0 (column counter)
    mov rsi, [rsp+8]    ; Restore B matrix pointer

.loop_b_cols:
    xor r10, r10        ; r10 = k = 0 (inner product counter)
    
    ; Calculate base address for A[i][k]
    mov rax, r8         ; i
    imul rax, r15       ; i * a_cols
    shl rax, 2          ; i * a_cols * 4
    add rax, r11        ; &A[i][0]

    ; Initialize accumulators
    vxorps ymm15, ymm15, ymm15  ; c[i][j:j+8]
    vxorps ymm14, ymm14, ymm14  ; c[i][j+8:j+16]
    vxorps ymm13, ymm13, ymm13  ; c[i+1][j:j+8]
    vxorps ymm12, ymm12, ymm12  ; c[i+1][j+8:j+16]
    vxorps ymm11, ymm11, ymm11  ; c[i+2][j:j+8]
    vxorps ymm10, ymm10, ymm10  ; c[i+2][j+8:j+16]
    vxorps ymm9, ymm9, ymm9     ; c[i+3][j:j+8]
    vxorps ymm8, ymm8, ymm8     ; c[i+3][j+8:j+16]
    vxorps ymm7, ymm7, ymm7     ; c[i+4][j:j+8]
    vxorps ymm6, ymm6, ymm6     ; c[i+4][j+8:j+16]
    vxorps ymm5, ymm5, ymm5     ; c[i+5][j:j+8]
    vxorps ymm4, ymm4, ymm4     ; c[i+5][j+8:j+16]

    ; Calculate B's base address for B[k][j]
    mov rcx, r9         ; j
    imul rcx, r15       ; j * b_rows
    shl rcx, 2          ; j * b_rows * 4
    add rcx, rsi        ; &B[0][j]

    align 16
.loop_dotprod:
    ; Load B blocks
    vmovaps ymm0, [rcx]        ; ymm0 = B[k][j:j+8]
    vmovaps ymm1, [rcx + 32]   ; ymm1 = B[k][j+8:j+16]

    ; Calculate address for A[i][k]
    lea rdx, [rax + 4*r10]     ; rdx = &A[i][k]
    
    ; Process row i
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm15, ymm2, ymm0
    vfmadd231ps ymm14, ymm2, ymm1

    ; Process row i+1
    add rdx, rbx               ; Move to next row
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm13, ymm2, ymm0
    vfmadd231ps ymm12, ymm2, ymm1

    ; Process row i+2
    add rdx, rbx               ; Move to next row
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm11, ymm2, ymm0
    vfmadd231ps ymm10, ymm2, ymm1

    ; Process row i+3
    add rdx, rbx               ; Move to next row
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm9, ymm2, ymm0
    vfmadd231ps ymm8, ymm2, ymm1

    ; Process row i+4
    add rdx, rbx               ; Move to next row
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm7, ymm2, ymm0
    vfmadd231ps ymm6, ymm2, ymm1

    ; Process row i+5
    add rdx, rbx               ; Move to next row
    vbroadcastss ymm2, [rdx]
    vfmadd231ps ymm5, ymm2, ymm0
    vfmadd231ps ymm4, ymm2, ymm1

    add rcx, 64         ; Move to next B block
    inc r10             ; k++
    cmp r10, r15        ; k < b_rows
    jl .loop_dotprod

    ; Store results in C
    mov rax, r8         ; i
    imul rax, r13       ; i * b_cols
    add rax, r9         ; i * b_cols + j
    shl rax, 2          ; Convert to bytes
    mov rdx, [rsp]      ; Restore C pointer
    add rax, rdx        ; Get actual address in C

    mov rcx, r13
    shl rcx, 2          ; rcx = b_cols * 4 (C stride)

    ; Store all rows
    vmovaps [rax], ymm15
    vmovaps [rax + 32], ymm14
    
    add rax, rcx
    vmovaps [rax], ymm13
    vmovaps [rax + 32], ymm12
    
    add rax, rcx
    vmovaps [rax], ymm11
    vmovaps [rax + 32], ymm10
    
    add rax, rcx
    vmovaps [rax], ymm9
    vmovaps [rax + 32], ymm8
    
    add rax, rcx
    vmovaps [rax], ymm7
    vmovaps [rax + 32], ymm6
    
    add rax, rcx
    vmovaps [rax], ymm5
    vmovaps [rax + 32], ymm4

    add r9, 16          ; j += 16
    cmp r9, r13         ; j < b_cols
    jl .loop_b_cols

    add r8, 6           ; i += 6
    cmp r8, r14         ; i < a_rows
    jl .loop_a_rows

    ; Success - return C matrix pointer
    mov rax, [rsp]      ; Return C pointer
    jmp .cleanup

.error:
    xor rax, rax        ; Return null on error

.cleanup:
    ; Restore stack and preserved registers
    lea rsp, [rbp-40]   ; Restore stack pointer (40 = 5 pushed registers)
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret