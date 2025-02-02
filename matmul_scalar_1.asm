%include "header.inc"
global main
extern printf

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
main:
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


        ; calling printf to display the result inside xmm2 
        cvtss2sd xmm0, xmm2 
        lea rdi, [rel fmt] ; address of label
        mov rax, 1       ; AL=1
        push rbx
        push r11
        push r10
        call printf
        pop r10
        pop r11
        pop rbx

        ; Save dotprod into c_matrix_rmaj[i][j]
        mov rax, r10              ; rax = i
        imul rax, [b_matrix_cols] ; rax = i * b_matrix_cols
        add rax, r11              ; rax = (i * b_matrix_cols) + j
        shl rax, 2                ; multiply by 4 for float32
        movss [c_matrix_rmaj + rax*4], xmm2 ; store dot product
    

    inc r11
    cmp r11,[b_matrix_cols] ; loop control
    jl .loop_b_cols

inc r10
cmp r10,[a_matrix_rows] ; loop control
jl .loop_a_rows


exit 0

