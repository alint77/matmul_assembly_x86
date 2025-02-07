%include "header.inc"

section .data
    align 32
    a_matrix_rmaj times 1048576 dd 2.1 ;
    a_matrix_rows dq 1024
    a_matrix_cols dq 1024
    align 32
    b_matrix_cmaj times 1048576 dd -3.1;
    b_matrix_rows dq 1024
    b_matrix_cols dq 1024
    align 32
    perm_mask dd 0,2,4,6,1,3,5,7

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

    vxorps ymm15,ymm15,ymm15 ; accumulator c[i][j]
    vxorps ymm14,ymm14,ymm14 ; accumulator c[i][j+1]
    vxorps ymm13,ymm13,ymm13 ; accumulator c[i+1][j]
    vxorps ymm12,ymm12,ymm12 ; accumulator c[i+1][j+1]
    
    .loop_dotprod:
        
        vmovaps ymm0,  [a_matrix_rmaj+r14*4]       ;  ymm0 = a[i][k] = a[i*a_cols + k]
        vmovaps ymm1,  [a_matrix_rmaj+r9+r14*4]    ;  ymm1 = a[i+1][k] = a[(i+1)*a_cols + k]
        vmovaps ymm2,  [b_matrix_cmaj+r15*4]       ;  ymm2 = b[k][j] = b[i*b_rows + k]
        vmovaps ymm3,  [b_matrix_cmaj+r9+r15*4]    ;  ymm3 = b[k][j+1] = b[(j+1)*b_rows + k]


        vfmadd231ps ymm15,ymm0,ymm2 ; c[i][j]
        vfmadd231ps ymm14,ymm0,ymm3 ; c[i][j+1]
        vfmadd231ps ymm13,ymm1,ymm2 ; c[i+1][j]
        vfmadd231ps ymm12,ymm1,ymm3 ; c[i+1][j+1]

        add r15,8
        add r14,8
        dec r12

        jnz .loop_dotprod


        vhaddps ymm15,ymm15,ymm14 
        vhaddps ymm13,ymm13,ymm12

        vhaddps ymm15,ymm15,ymm13 ; [al,bl,cl,dl,ah,bh,ch,dh]

        vmovdqa ymm13,[perm_mask] ; [0,2,4,6,1,3,5,7]

        vpermps ymm15,ymm13,ymm15 ; [al,ah,bl,bh,cl,ch,dl,dh]

        vhaddps ymm15,ymm15,ymm15 ; [a,b,a,b,c,d,d]

        

        ; Save dotprod into c_matrix_rmaj[i][j]
        mov rax, r10               ; rax = i
        imul rax, r13             ; rax = i * b_matrix_cols
        add rax, r11               ; rax = (i * b_matrix_cols) + j
        shl rax, 2                 ; multiply by 4 for float32

        vextractf128 xmm1, ymm15, 0      ; lower half = a,b,a,b
        vmovlps      [c_matrix_rmaj + rax], xmm1        ; store a,b (two floats)
        
        add rax,r13
        vextractf128 xmm2, ymm15, 1      ; upper half = c,d,c,d
        vmovlps      [c_matrix_rmaj + rax], xmm2      ; store c,d (two floats)

    add r11,2
    cmp r11,[b_matrix_cols] ; loop control
    jl .loop_b_cols

add r10,2
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
leave
exit 0
