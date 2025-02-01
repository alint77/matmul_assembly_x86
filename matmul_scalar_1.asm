%include "header.inc"

section .data
    a_matrix_rmaj: times 5 dd 2.0,3.0,4.0
    a_matrix_rows: dq 5
    a_matrix_cols: dq 3
    b_matrix_rmaj: times 3 dd 2.0,3.0,4.0,5.0
    b_matrix_rows: dq 3
    b_matrix_cols: dq 4
section .bss

section .text
global _start

_start: 

    exit 0
