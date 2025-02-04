%include "header.inc"

section .data
    a_matrix_rmaj: dd 2.1,3.1,4.1 , 5.1,6.1,7.1 , 8.1,9.1,10.1 , 11.1,12.1,13.1 , 14.1,15.1,16.1
    a_matrix_rows: dq 5
    a_matrix_cols: dq 3
    b_matrix_rmaj: dd 2.1,3.1,4.1,5.1 , 2.1,3.1,4.1,5.1 , 2.1,3.1,4.1,5.1
    b_matrix_rows: dq 3
    b_matrix_cols: dq 4

    fmt: db "%f", 0x0a, 0

section .bss
    c_matrix_rmaj: resd 20

section .text
global main
extern printf
extern _exit

main:
push rbp
mov rbp,rsp
sub rsp,8

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
        add r8,r11; r8 = [k*b_cols + j] = [k][j]
        
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

mov rdi,20
lea rsi,[rel c_matrix_rmaj]
call _printf_arr_f32

add rsp,8
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

