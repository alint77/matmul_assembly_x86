%include "header.inc"

section .data
    a_matrix_rmaj: dd 2.0,3.0,4.0 , 5.0,6.0,7.0 , 8.0,9.0,10.0 , 11.0,12.0,13.0 , 14.0,15.0,16.0
    a_matrix_rows: dq 5
    a_matrix_cols: dq 3
    b_matrix_rmaj: dd 2.0,3.0,4.0,5.0 , 2.0,3.0,4.0,5.0 , 2.0,3.0,4.0,5.0
    b_matrix_rows: dq 3
    b_matrix_cols: dq 4

    msg: db "hello!",10

section .bss
    num resb 9 
section .text
global _start

_start:
xor rbx,rbx
xor r10,r10 ; i
.loop_a_rows:
xor r11,r11 ; j
.loop_b_cols:
    xor r12,r12 ; k
    xor r13,r13 ; sum
    .loop_dotprod:

        ; logic
        inc rbx



        inc r12
        cmp r12,[a_matrix_cols]
        jl .loop_dotprod

    inc r11
    cmp r11,[b_matrix_cols]
    jl .loop_b_cols

inc r10
cmp r10,[a_matrix_rows]
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
