%include "header.inc"

section .data
    align 32
    a_matrix_rmaj times 131072 dd 2.1, -5.7, 4.1, 1.3, 2.1, -5.7, 4.1, 1.3 ;
    a_matrix_rows dq 1024
    a_matrix_cols dq 1024
    align 32
    b_matrix_cmaj times 131072 dd -3.1, 4.3, 1.7, 3.1, 2.1, -5.7, 4.1, 1.3 ;
    b_matrix_rows dq 1024
    b_matrix_cols dq 1024

    fmt db "%f", 0x0a, 0
    fmt_time: db "Wall time: %.6f s", 0x0a, 0
    one_billion: dq 1000000000.0  ; 1e9 as a double

section .bss
    align  32
    c_matrix_rmaj resd 1048576
    start_time resq 2
    end_time resq 2

section .text
global main
extern printf, clock_gettime

main:
push rbp
mov rbp,rsp
sub rsp,32

; ==== Get start time ====
mov rdi, 1              ; CLOCK_MONOTONIC
lea rsi, [rel start_time]
call clock_gettime      ; Call libC function (easier than syscall)



xor r10,r10 ; r10 = i = 0
mov r9,[a_matrix_cols] ; cache, r9 = a_matrix_cols
mov r13,[b_matrix_cols] ; cache, r13 = b_matrix_cols
.loop_a_rows:

xor r11,r11 ; j = 0
.loop_b_cols:

    ; ; Calculate base addresses for A's row and B's column
    ; mov rax, r10
    ; imul rax, r9         ; rax = i * 1024
    ; shl rax, 2           ; rax = i * 1024 * 4 (byte offset)
    ; lea r14, [rel a_matrix_rmaj + rax] ; A[i][0]

    ; mov rax, r11
    ; imul rax, r9         ; rax = j * 1024
    ; shl rax, 2           ; rax = j * 1024 * 4
    ; lea r15, [rel b_matrix_cmaj + rax] ; B[0][j]

    mov r12,r9 ; k = a_cols (gets decremented on each iteration)
    shr r12,3
    mov r15,r11 ; r15 = j
    imul r15,r9 ; r15 = j*b_rows = j*a_cols
    
    mov r14,r10 ; r14 = i
    imul r14,r9 ; r14 = i*a_matrix_cols

    vxorps ymm2,ymm2,ymm2 ; accumulator

    .loop_dotprod:

        vmovaps ymm0,  [a_matrix_rmaj+r14*4]    ;  ymm0 = a[i][k] = a[i*a_cols + k]
        vmovaps ymm1,  [b_matrix_cmaj+r15*4]    ;  ymm1 = b[k][j] = b[j*a_cols + k]
        
        vfmadd231ps ymm2,ymm0,ymm1

        add r15,8
        add r14,8
        dec r12
        jnz .loop_dotprod

        ; Horizontal sum of ymm2 into scalar
        vextractf128 xmm0, ymm2, 1  ; Extract upper 128 bits
        vaddps xmm1, xmm0, xmm2     ; Combine halves
        vhaddps xmm1, xmm1, xmm1    ; Horizontal add
        vhaddps xmm1, xmm1, xmm1    ; Final sum in xmm1[0]

        ; Save dotprod into c_matrix_rmaj[i][j]
        mov rax, r10               ; rax = i
        imul rax, r13             ; rax = i * b_matrix_cols
        add rax, r11               ; rax = (i * b_matrix_cols) + j
        shl rax, 2                 ; multiply by 4 for float32
        movss  [c_matrix_rmaj + rax], xmm1 ; store dot product

    inc r11
    cmp r11,[b_matrix_cols] ; loop control
    jl .loop_b_cols

inc r10
cmp r10,[a_matrix_rows] ; loop control
jl .loop_a_rows

; mov rdi,512
; mov rsi,c_matrix_rmaj
; call _printf_arr_f32

; ==== Get end time ====
mov rdi, 1              ; CLOCK_MONOTONIC
lea rsi, [rel end_time]
call clock_gettime

; ==== Calculate elapsed time ====
; Compute seconds and nanoseconds difference
mov rax, [end_time]             ; end_sec
sub rax, [start_time]           ; - start_sec = seconds_diff
mov rcx, [end_time + 8]         ; end_nsec
sub rcx, [start_time + 8]       ; - start_nsec = nsec_diff

; Handle negative nanoseconds (borrow from seconds)
cmp rcx, 0
jge .positive
add rcx, 1000000000     ; Add 1e9 nanoseconds
dec rax                 ; Subtract 1 second

.positive:

; Convert to floating-point seconds
cvtsi2sd xmm0, rax      ; seconds_diff as double
cvtsi2sd xmm1, rcx      ; nsec_diff as double
divsd xmm1, [rel one_billion]  ; nsec_diff / 1e9
addsd xmm0, xmm1        ; total_seconds = seconds_diff + nsec_diff/1e9

; ==== Print the result ====
lea rdi, [rel fmt_time] ; Format string
mov rax, 1              ; 1 vector register used (xmm0)
call printf


add rsp,32
exit 0
