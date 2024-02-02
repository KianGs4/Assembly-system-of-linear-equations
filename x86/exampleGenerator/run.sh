#!/bin/bash
touch inputs
touch outputs
g++ $1.cpp -o $1 &&
g++ randomMatrixGenerator.cpp -o RMG && ./RMG && ./$1	
#gcc -m64 -no-pie -std=c17 -c driver.c
#nasm -f elf64 $1.asm &&
#gcc -m64 -no-pie -std=c17 -o $1 driver.c $1.o  && ./$1


#for i in {0..10}
#do 
#   touch temp.$i
#done 

