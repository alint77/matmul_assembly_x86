nasm -f elf64 $1 -o m.o -g  -F dwarf
# ld m.o
gcc -no-pie m.o -g -lrt
./a.out
# echo 'exit code:' $?
rm -f *.o