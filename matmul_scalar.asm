
; PRACTICE FILE. PLEASE IGNORE. IMPLEMENTATIONS START AT *_1.asm

%include "header.inc"

SECTION .data

    text_str: db "testing!",10,0
    msg: db "Hello!",0xA
    msg_len: equ $-msg

SECTION .bss
num resb 9
name resb 8

SECTION .text

global _start
global main

_start:
main:
    
    
    call _print_msg
    mov rcx,0x8
    call _print_rcx
    ; call _getInput

    mov rax,text_str
    call _print_str

    exit 0

_print_msg: 
    mov rax,SYS_WRITE
    mov rdi,STDOUT
    mov rsi,msg
    mov rdx,msg_len
    syscall 
    ret

_getInput:
    mov rax,SYS_READ
    mov rdi,STDIN
    mov rsi,name
    mov rdx,8
    syscall
    push rsi
    ret

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
;input: rax as ptr to nullterminated str
;output: print nullterminated str to stdout
_print_str:

    push rax
    mov rbx,0

.printLoop:

    inc rax
    inc rbx
    mov cl,[rax]
    cmp cl,0
    jne .printLoop

    mov rax,SYS_WRITE
    mov rdi,STDOUT
    pop rsi
    mov rdx,rbx
    syscall
    ret



