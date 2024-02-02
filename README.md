# Assembly-system-of-linear-equations
solving system of linear equations with assembly x86  and IBM

Install stuff:
apt install build-essential gcc-s390x-linux-gnu gdb-multiarch qemu-user

For M1 owners:
apt install gcc-x86-64-linux-gnu

Compile for IBM (If compiling assembly, remember the .s extension!):
s390x-linux-gnu-gcc -static -fno-pie -no-pie -ggdb3 -o ibm main.c

Compile for Intel (If compiling assembly, remember the .s extension!):
x86_64-linux-gnu-gcc -static -fno-pie -no-pie -ggdb3 -o intel main.c

Get IBM Assembly:
s390x-linux-gnu-gcc -S -fno-pie -no-pie -o ibm.s main.c

Get Intel Assembly:
x86_64-linux-gnu-gcc -S -fno-pie -no-pie -masm=intel -o intel.s main.c

