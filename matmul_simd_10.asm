%include "header.inc"
; TODO: WRITE matrix rowmaj to custom 3x4 : write C or python first
section .data
    align 4
    a_matrix_rmaj times 1152*1152 dd 2.1 ;
    a_matrix_rows dq 1152
    a_matrix_cols dq 1152
    align 32
    b_matrix_blocking times 1152*1152 dd -3.1;
    b_matrix_rows dq 1152
    b_matrix_cols dq 1152
    align 32
    perm_mask dd 0,2,4,6,1,3,5,7

    fmt db "%f", 0x0a, 0
    fmt_time: db "Wall time: %.6f s", 0x0a, 0
    one_billion: dq 1000000000.0  ; 1e9 as a double

section .bss
    align  32
    c_matrix_rmaj resd 1152*1152
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

mov r15,[b_matrix_rows] ; = a_matrix_cols
mov r14,[a_matrix_rows]
mov r13,[b_matrix_cols]

mov rbx,r15
shl rbx,2 ; a_cols*4

mov rdi,rbx
imul rdi,3

mov rsi,rbx
imul rsi,5


xor r8,r8 ; r8  = i=0 ; i<a_rows ; i+=6
.loop_a_rows:
xor r9,r9 ; r9  = j=0 ; j<b_cols ; j+=64
.loop_b_cols:

    xor r10,r10  ; r10 = k=0 ; k<b_rows ; k++
    
    ; r11 = i*a_cols*4
    mov r11,r8
    imul r11,r15
    shl r11,2
    

    vxorps xmm15,xmm15,xmm15 ; accumulator ymm15 = c[i]  [j]   j+8
    vxorps xmm14,xmm14,xmm14 ; accumulator ymm14 = c[i]  [j+1]
    vxorps xmm13,xmm13,xmm13 ; accumulator ymm13 = c[i+1][j]
    vxorps xmm12,xmm12,xmm12 ; accumulator ymm12 = c[i+1][j+1]
    vxorps xmm11,xmm11,xmm11 ; accumulator ymm11 = c[i+2][j]
    vxorps xmm10,xmm10,xmm10 ; accumulator ymm10 = c[i+2][j+1]
    vxorps xmm9,xmm9,xmm9    ; accumulator ymm9  = c[i+3][j]
    vxorps xmm8,xmm8,xmm8    ; accumulator ymm8  = c[i+3][j+1]
    vxorps xmm7,xmm7,xmm7    ; accumulator ymm7  = c[i+4][j]
    vxorps xmm6,xmm6,xmm6    ; accumulator ymm6  = c[i+4][j+1]
    vxorps xmm5,xmm5,xmm5    ; accumulator ymm5  = c[i+5][j]
    vxorps xmm4,xmm4,xmm4    ; accumulator ymm4  = c[i+5][j+1]

    ;b[k][j:j+8) = b [1][16:24) = 16*b_rows + 1*16 + 16/16 = (j*b_rows + k*16 + k/16)*4

    ;j*b_rows*4
    mov r12,r9
    imul r12,r15
    shl r12,2


    .loop_dotprod: ; 6x2(x8) kernel:  8 mem reads for 12(x8) c elements => 0.66 mem reads per element 
        align 32
        lea rax,[a_matrix_rmaj + r11 + 4*r10] ; rax = a[i][k] = 
        vmovaps ymm0,  [b_matrix_blocking+r12 ]   ;  ymm0 = b[k][j:j+8)   k*b_cols*4 + j
        vmovaps ymm1,  [b_matrix_blocking+r12 +  32]   ;  ymm1 = b[k][j+8,j+16)
        vbroadcastss ymm2,  [rax]           ;  ymm2 = a[i][k] = a[i*a_cols*4 + k*4]
        
        vfmadd231ps ymm15,ymm2,ymm0 ; c[i][j]
        vfmadd231ps ymm14,ymm2,ymm1 ; c[i][j+1]
        vbroadcastss ymm3,  [rax+rbx] ;  ymm3 = a[i+1][k] = a[(i+1)*a_cols*4 + k*4]
        vfmadd231ps ymm13,ymm3,ymm0 ; c[i+1][j]
        vfmadd231ps ymm12,ymm3,ymm1 ; c[i+1][j+1]

        vbroadcastss ymm2,  [rax+2*rbx] ;  ymm2 = a[i+2][k] = a[(i+2)*a_cols*4 + k*4]

        vfmadd231ps ymm11,ymm2,ymm0 ; c[i+2][j]
        vfmadd231ps ymm10,ymm2,ymm1 ; c[i+2][j+1]
        vbroadcastss ymm3,  [rax+rdi] ;  ymm3 = a[i+3][k] = a[(i+3)*a_cols*4 + k*4]
        vfmadd231ps ymm9,ymm3,ymm0 ; c[i+3][j]
        vfmadd231ps ymm8,ymm3,ymm1 ; c[i+3][j+1]

        vbroadcastss ymm2,  [rax+4*rbx] ;  ymm2 = a[i+4][k] = a[(i+4)*a_cols*4 + k*4]

        vfmadd231ps ymm7,ymm2,ymm0 ; c[i+4][j]
        vfmadd231ps ymm6,ymm2,ymm1 ; c[i+4][j+1]
        vbroadcastss ymm3,  [rax+rsi] ;  ymm3 = a[i+5][k] = a[(i+5)*a_cols*4 + k*4]
        vfmadd231ps ymm5,ymm3,ymm0 ; c[i+5][j]
        vfmadd231ps ymm4,ymm3,ymm1 ; c[i+5][j+1]


        add r12,64
        inc r10 ; k++
        cmp r10,r15 ; k < b_matrix_rows
        jl .loop_dotprod

        
    .save_c:
    ; Calculate base address for storing in C
    mov rax, r8          ; rax = i
    imul rax, r13        ; rax = i * b_cols
    add rax, r9          ; rax = i * b_cols + j
    shl rax, 2          ; multiply by 4 (for float32)
    
    mov r12,r13
    shl r12,2 ; r12 = b_cols*4

    ; Store first row (ymm15, ymm14)
    vmovaps [c_matrix_rmaj + rax], ymm15        ; store c[i][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm14   ; store c[i][j+8:j+16]
    
    ; Store second row (ymm13, ymm12)
    add rax, r12        ; next row offset
    vmovaps [c_matrix_rmaj + rax], ymm13        ; store c[i+1][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm12   ; store c[i+1][j+8:j+16]
    
    ; Store third row (ymm11, ymm10)
    add rax, r12
    vmovaps [c_matrix_rmaj + rax], ymm11        ; store c[i+2][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm10   ; store c[i+2][j+8:j+16]
    
    ; Store fourth row (ymm9, ymm8)
    add rax, r12
    vmovaps [c_matrix_rmaj + rax], ymm9         ; store c[i+3][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm8    ; store c[i+3][j+8:j+16]
    
    ; Store fifth row (ymm7, ymm6)
    add rax, r12
    vmovaps [c_matrix_rmaj + rax], ymm7         ; store c[i+4][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm6    ; store c[i+4][j+8:j+16]
    
    ; Store sixth row (ymm5, ymm4)
    add rax, r12
    vmovaps [c_matrix_rmaj + rax], ymm5         ; store c[i+5][j:j+8]
    vmovaps [c_matrix_rmaj + rax + 32], ymm4    ; store c[i+5][j+8:j+16]
    .end_save_c:


    add r9,16
    cmp r9,[b_matrix_cols] ; loop control j
    jl .loop_b_cols

add r8,6
cmp r8,[a_matrix_rows] ; loop control i
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
