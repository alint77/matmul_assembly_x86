nasm -f elf64 $1 -o m.o -g
# ld m.o
gcc -no-pie -z noexecstack m.o -lrt -g
./a.out
# echo 'exit code:' $?
rm -f *.o