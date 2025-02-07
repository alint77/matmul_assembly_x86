%include "header.inc"

section .data
    align 32
    a_matrix_rmaj times 1048576 dd 2.1 ;
    a_matrix_rows dq 1032
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
    c_matrix_rmaj resd 1056768
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

    mov r12,r9  ; k = a_cols (gets decremented on each iteration)
    shr r12,3   ; k /= 8 for simd

    mov r15,r11 ; r15 = j
    imul r15,r9 ; r15 = j*b_rows = j*a_cols

    mov r14,r10 ; r14 = i
    imul r14,r9 ; r14 = i*a_cols

    mov r8,r9
    shl r8,2    ; r8  = a_cols*4 = b_rows*4

    mov rbx,r8  ; 
    imul rbx,3  ; rbx = r8*3

    shl r14,2   ; r14 = i*a_cols*4
    shl r15,2   ; r15 = j*b_rows*4

    vxorps ymm15,ymm15,ymm15 ; accumulator ymm15 = c[i][j]
    vxorps ymm14,ymm14,ymm14 ; accumulator ymm14 = c[i][j+1]
    vxorps ymm13,ymm13,ymm13 ; accumulator ymm13 = c[i][j+2]
    vxorps ymm12,ymm12,ymm12 ; accumulator ymm12 = c[i][j+3]
    vxorps ymm11,ymm11,ymm11 ; accumulator ymm11 = c[i+1][j]
    vxorps ymm10,ymm10,ymm10 ; accumulator ymm10 = c[i+1][j+1]
    vxorps ymm9,ymm9,ymm9    ; accumulator ymm9  = c[i+1][j+2]
    vxorps ymm8,ymm8,ymm8    ; accumulator ymm8  = c[i+1][j+3]
    vxorps ymm7,ymm7,ymm7    ; accumulator ymm7  = c[i+2][j]
    vxorps ymm6,ymm6,ymm6    ; accumulator ymm6  = c[i+2][j+1]
    vxorps ymm5,ymm5,ymm5    ; accumulator ymm5  = c[i+2][j+2]
    vxorps ymm4,ymm4,ymm4    ; accumulator ymm4  = c[i+2][j+3]

    .loop_dotprod: ; 3x4 kernel:  7 mem reads for 12 c elements => 0.58 read per element 
        
        ; iterating over 3 lines of a and 4 columns of b:

        vmovaps ymm1,  [a_matrix_rmaj+r14]
        vmovaps ymm2,  [a_matrix_rmaj+r14 +r8]
        vmovaps ymm3,  [a_matrix_rmaj+r14 +2*r8]

        vmovaps ymm0,  [b_matrix_cmaj+r15]       ;  ymm0 = b[k][j] = b[i*b_rows + k]

        vfmadd231ps ymm15,ymm0,ymm1 ; c[i][j]
        vfmadd231ps ymm11,ymm0,ymm2 ; c[i+1][j]
        vfmadd231ps ymm7,ymm0,ymm3 ; c[i+2][j]

        vmovaps ymm0,  [b_matrix_cmaj+r15+r8]    ;  ymm0 = b[k][j+1] = b[(j+1)*b_rows + k]
        
        vfmadd231ps ymm14,ymm0,ymm1  ; c[i][j+1]
        vfmadd231ps ymm10,ymm0,ymm2  ; c[i+1][j+1]
        vfmadd231ps ymm6,ymm0,ymm3  ; c[i+2][j+1]

        vmovaps ymm0,  [b_matrix_cmaj+r15+r8*2]  ;  ymm0 = b[k][j+2] = b[(j+2)*b_rows + k]

        vfmadd231ps ymm13,ymm0,ymm1  ; c[i][j+2]
        vfmadd231ps ymm9,ymm0,ymm2  ; c[i+1][j+2]
        vfmadd231ps ymm5,ymm0,ymm3  ; c[i+2][j+2]

        vmovaps ymm0,  [b_matrix_cmaj+r15+rbx]   ;  ymm0 = b[k][j+3] = b[(j+3)*b_rows + k]

        vfmadd231ps ymm12,ymm0,ymm1  ; c[i][j+3]
        vfmadd231ps ymm8,ymm0,ymm2  ; c[i+1][j+3]
        vfmadd231ps ymm4,ymm0,ymm3  ; c[i+2][j+3]
        

        add r15,32
        add r14,32
        dec r12

        jnz .loop_dotprod

        
        ; calculating horizontal add (reduce to single float32 scalar) for c[i][j:j+4]
        vhaddps ymm15,ymm15,ymm14 
        vhaddps ymm13,ymm13,ymm12

        vhaddps ymm15,ymm15,ymm13 ; => [al,bl,cl,dl,ah,bh,ch,dh]

        vmovdqa ymm13,[perm_mask] ; [0,2,4,6,1,3,5,7]

        vpermps ymm15,ymm13,ymm15 ; => [al,ah,bl,bh,cl,ch,dl,dh]

        vhaddps ymm15,ymm15,ymm15 ; => [a,b,a,b,c,d,d]

        ; calculating horizontal add (reduce to single float32 scalar) for c[i+1][j:j+4]
        vhaddps ymm11,ymm11,ymm10 
        vhaddps ymm9,ymm9,ymm8

        vhaddps ymm11,ymm11,ymm9 ; [al,bl,cl,dl,ah,bh,ch,dh]

        vmovdqa ymm9,[perm_mask] ; [0,2,4,6,1,3,5,7]

        vpermps ymm11,ymm9,ymm11 ; [al,ah,bl,bh,cl,ch,dl,dh]

        vhaddps ymm11,ymm11,ymm11 ; [a,b,a,b,c,d,d]

        ; calculating horizontal add (reduce to single float32 scalar) for c[i+2][j:j+4]
        vhaddps ymm7,ymm7,ymm6 
        vhaddps ymm5,ymm5,ymm4

        vhaddps ymm7,ymm7,ymm5 ; [al,bl,cl,dl,ah,bh,ch,dh]

        vmovdqa ymm5,[perm_mask] ; [0,2,4,6,1,3,5,7]

        vpermps ymm7,ymm5,ymm7 ; [al,ah,bl,bh,cl,ch,dl,dh]

        vhaddps ymm7,ymm7,ymm7 ; [a,b,a,b,c,d,d]


        ; Save dotprod into c_matrix_rmaj
        mov rax, r10               ; rax = i
        imul rax, r13             ; rax = i * b_matrix_cols
        add rax, r11               ; rax = (i * b_matrix_cols) + j
        shl rax, 2                 ; multiply by 4 for float32

        vextractf128 xmm1, ymm15, 0      ; lower half = a,b,a,b
        vmovlps      [c_matrix_rmaj + rax], xmm1        ; store a,b (two floats)
        vextractf128 xmm2, ymm11, 0      ; lower half = a,b,a,b
        vmovlps      [c_matrix_rmaj + r13*4 + rax], xmm2        ; store a,b (two floats)
        vextractf128 xmm3, ymm7, 0       ; lower half = a,b,a,b
        vmovlps      [c_matrix_rmaj + r13*8 + rax], xmm3        ; store a,b (two floats)
        
        
        add rax,8

        vextractf128 xmm3, ymm15, 1      ; upper half = c,d,c,d
        vmovlps      [c_matrix_rmaj + rax], xmm3      ; store c,d (two floats)
        vextractf128 xmm4, ymm11, 1      ; upper half = c,d,c,d
        vmovlps      [c_matrix_rmaj + r13*4 + rax], xmm4      ; store c,d (two floats)
        vextractf128 xmm4, ymm7, 1       ; upper half = c,d,c,d
        vmovlps      [c_matrix_rmaj + r13*8 + rax], xmm4      ; store c,d (two floats)


    add r11,4
    cmp r11,[b_matrix_cols] ; loop control i
    jl .loop_b_cols

add r10,3
cmp r10,[a_matrix_rows] ; loop control i
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
