%ifndef HEADERFILE
%define HEADERFILE

%define STDIN  0
%define STDOUT  1
%define STDERR  2
%define O_WRONLY  1
%define O_CREAT   64
%define O_APPEND  1024
%define S_IRUSR   0400
%define S_IWUSR   0200

%define SYS_READ  0
%define SYS_WRITE  1
%define SYS_EXIT  60
%define SYS_OPEN  2
%define SYS_WRITE 1
%define SYS_CLOSE 3


%macro exit 1
    mov rax,SYS_EXIT
    mov rdi,%1
    syscall
%endmacro

%endif

