nasm -f elf64 $1 -o m.o -O2
# ld m.o
gcc -no-pie m.o -lrt
./a.out
# echo 'exit code:' $?
rm -f *.o