%include "header.inc"

section .data
    a_matrix_rmaj times 131072 dd 2.1, -5.7, 4.1, 1.3, 2.1, -5.7, 4.1, 1.3 ;512
    a_matrix_rows dq 1024
    a_matrix_cols dq 1024
    b_matrix_rmaj times 131072 dd -3.1, 4.3, 1.7, 3.1, 2.1, -5.7, 4.1, 1.3 ;1024
    b_matrix_rows dq 1024
    b_matrix_cols dq 1024

    fmt db "%f", 0x0a, 0
    fmt_time: db "Wall time: %.6f ms", 0x0a, 0
    one_million: dq 1000000.0  ; 1e9 as a double

section .bss
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

; ==== (1) Get start time ====
mov rdi, 1              ; CLOCK_MONOTONIC
lea rsi, [rel start_time]
call clock_gettime      ; Call C function (easier than syscall)

xor r10,r10 ; i
.loop_a_rows:
xor r11,r11 ; j
.loop_b_cols:
    xor r12,r12 ; k
    xorps xmm2,xmm2 ; accumulator
    .loop_dotprod:
        
        mov r14,r10; r14 used for mat1 idx
        imul r14,[a_matrix_cols]
        add r14,r12; r14 = [i*a_cols + k] = [i][k]
        
        movss xmm0,  [a_matrix_rmaj+r14*4]    ;  xmm0 used for a[i][k]
        
        mov r8,r12 ; r8 holds k
        imul r8,[b_matrix_cols]
        add r8,r11; r8 = [k*b_rows + j] = [k][j]
        
        movss xmm1,  [b_matrix_rmaj+r8*4]    ;  xmm1 used for b[k][j]

        mulss xmm0,xmm1 ; xmm0 = a[i][k] * b[k][j] 

        addss xmm2,xmm0 ; xmm2 hold the dotprod so far

        inc r12
        cmp r12,[a_matrix_cols] ; loop control
        jl .loop_dotprod

        ; Save dotprod into c_matrix_rmaj[i][j]
        mov rax, r10              ; rax = i
        imul rax,  [b_matrix_cols] ; rax = i * b_matrix_cols
        add rax, r11              ; rax = (i * b_matrix_cols) + j
        shl rax, 2               ; multiply by 4 for float32
        movss  [c_matrix_rmaj + rax], xmm2 ; store dot product


    inc r11
    cmp r11,[b_matrix_cols] ; loop control
    jl .loop_b_cols

inc r10
cmp r10,[a_matrix_rows] ; loop control
jl .loop_a_rows

; mov rdi,512
; mov rsi,c_matrix_rmaj
; call _printf_arr_f32

; ==== (3) Get end time ====
mov rdi, 1              ; CLOCK_MONOTONIC
lea rsi, [rel end_time]
call clock_gettime

; ==== (4) Calculate elapsed time ====
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
divsd xmm1, [rel one_million]  ; nsec_diff / 1e9
addsd xmm0, xmm1        ; total_seconds = seconds_diff + nsec_diff/1e9

; ==== (5) Print the result ====
lea rdi, [rel fmt_time] ; Format string
mov rax, 1              ; 1 vector register used (xmm0)
call printf


add rsp,32
leave
ret

; void _printf_arr_f32 ( long {rdi}, float* {rsi} )
_printf_arr_f32:
    push rbp
    mov rbp, rsp
    push rdi                   ; Save loop counter (rdi)
    push rsi                   ; Save array pointer (rsi)
    
    lea rdi, [rel fmt]         ; Load format string address once

.loop:
    push rdi                   ; Save format string
    push rsi                   ; Save current array pointer

    movss xmm0, [rsi]          ; Load float from array
    cvtss2sd xmm0, xmm0        ; Convert to double for printf

    sub rsp, 8                 ; Align stack to 16 bytes
    mov rax, 1                 ; AL = 1 (1 vector register used)
    call printf
    add rsp, 8                 ; Restore stack alignment

    pop rsi                    ; Restore array pointer
    pop rdi                    ; Restore format string

    add rsi, 4                 ; Move to next element
    dec qword [rbp - 8]        ; Decrement loop counter (saved rdi)
    jnz .loop

.done:
    pop rsi                    ; Restore original rsi
    pop rdi                    ; Restore original rdi
    pop rbp
    ret

