STDIN equ 0
STDOUT equ 1
STDERR equ 2

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

%macro exit 1
    mov rax,SYS_EXIT
    mov rdi,%1
    syscall
%endmacro

