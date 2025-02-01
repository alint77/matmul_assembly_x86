nasm -f elf64 matmul_scalar.asm -o m.o 
ld m.o 
# gcc m.o
./a.out
echo 'exit code:' $?
rm -f *.o