%include "header.inc"

section .data
    a_matrix_rmaj: dd 2.0,3.0,4.0 , 5.0,6.0,7.0 , 8.0,9.0,10.0 , 11.0,12.0,13.0 , 14.0,15.0,16.0
    a_matrix_rows: dq 5
    a_matrix_cols: dq 3
    b_matrix_rmaj: dd 2.0,3.0,4.0,5.0 , 2.0,3.0,4.0,5.0 , 2.0,3.0,4.0,5.0
    b_matrix_rows: dq 3
    b_matrix_cols: dq 4


section .bss
    num: resb 9 
    c_matrix_rmaj: resd 20

section .text
global _start

_start:
xor rbx,rbx
xor r10,r10 ; i
.loop_a_rows:
xor r11,r11 ; j
.loop_b_cols:
    xor r12,r12 ; k
    xorps xmm2,xmm2 ; accumulator
    .loop_dotprod:

        ; logic
        inc rbx
        
        mov r14,r10; r14 used for mat1 idx
        imul r14,[a_matrix_cols]
        add r14,r12; r14 = [i*a_cols + k] = [i][k]
        
        movss xmm0,  [a_matrix_rmaj+r14*4]    ;  xmm0 used for a[i][k]
        
        mov r8,r12 ; r8 holds k
        imul r8,[b_matrix_rows]
        add r8,r11; r8 = [k*b_rows + j] = [k][j]
        
        movss xmm1,  [b_matrix_rmaj+r8*4]    ;  xmm1 used for b[k][j]

        mulss xmm0,xmm1 ; xmm0 = a[i][k] * b[k][j] 

        addss xmm2,xmm0 ; xmm2 hold the dotprod so far

        inc r12
        cmp r12,[a_matrix_cols] ; loop control
        jl .loop_dotprod

        ; TODO: mov sum to mat_C [i][j]
        ; Save dotprod into c_matrix_rmaj[i][j]
        mov rax, r10              ; rax = i
        imul rax, [b_matrix_cols] ; rax = i * b_matrix_cols
        add rax, r11              ; rax = (i * b_matrix_cols) + j
        shl rax, 2                ; multiply by 4 for float32
        movss [c_matrix_rmaj + rax], xmm2 ; store dot product

    inc r11
    cmp r11,[b_matrix_cols] ; loop control
    jl .loop_b_cols

inc r10
cmp r10,[a_matrix_rows] ; loop control
jl .loop_a_rows

mov rcx,rbx
call _print_rcx

exit 0


_print_rcx:
    add rcx,48
    mov [num],rcx
    mov rcx,10
    mov [num+8],rcx
    mov rax,SYS_WRITE
    mov rdi,STDOUT
    mov rsi,num
    mov rdx,9
    syscall 
    ret
