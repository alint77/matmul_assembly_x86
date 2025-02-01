nasm -f elf64 $1 -o m.o 
ld m.o 
# gcc m.o
./a.out
echo 'exit code:' $?
rm -f *.o