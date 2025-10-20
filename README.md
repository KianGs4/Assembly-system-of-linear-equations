# Assembly System of Linear Equations

A project to **solve systems of linear equations** using a mix of **C** and **assembly** (x86_64 and IBM s390x). The aim is to illustrate low-level implementations of Gaussian elimination (or related algorithms) in assembly, and compare performance or understand inner workings.

---

## Table of Contents

- [Motivation](#motivation)  
- [Features](#features)  
- [Repository Structure](#repository-structure)  
- [Requirements & Dependencies](#requirements--dependencies)  
- [Building & Compilation](#building--compilation)  
  - [Intel / x86_64 target](#intel--x86_64-target)  
  - [IBM / s390x target](#ibm--s390x-target)  
- [Usage / Running](#usage--running)  
---

## Motivation

Working in assembly is a great way to:

- deepen your understanding of CPU architecture, registers, memory, calling conventions  
- see exactly how arithmetic and control flow are implemented at the lowest level  
- benchmark assembly vs higher-level implementations  
- debug and inspect the behavior of numerical algorithms under the hood  

This project gives a hands-on example by implementing linear algebra (solving multiple linear equations) in assembly, while using C as a harness.

---

## Features

- Implementation in **x86_64 assembly** (Intel syntax)  
- Implementation in **IBM s390x assembly**  
- C wrapper / driver (`main.c`) to generate, feed, and verify data  
- Static linking to avoid external dependencies (in many cases)  
- Optionally produce the .s (assembly) output for inspection  

---

## Repository Structure

```
.
├── README.md
├── main.c
├── x86/
│   └── … (assembly files, helper routines)
├── IBM/
    └── … (assembly files, IBM-specific code)
```

- `main.c`: the entry point, handles input/output, assembling the matrix, invoking the assembly routines  
- `x86/`: contains assembly routines, maybe support macros, helpers  
- `IBM/`: contains the s390x-specific code  
---

## Requirements & Dependencies

To build and run across architectures:

- A Linux host (or cross-compilation environment)  
- GNU toolchain (gcc, as, ld)  
- Cross‑compilers / multiarch toolchains, depending on target (see below)  
- (Optional) `gdb-multiarch`, QEMU user-mode emulators for running foreign‑architecture binaries  
- On Debian/Ubuntu:  
  ```bash
  sudo apt update
  sudo apt install build-essential gcc-s390x-linux-gnu gdb-multiarch qemu-user
  ```
  If you’re on an M1 (ARM macOS) or other system, you might need an x86-64 cross compiler:
  ```bash
  sudo apt install gcc-x86-64-linux-gnu
  ```

---

## Building & Compilation

### Intel / x86_64 target

From the repository root:

```bash
# compile C + assembly into the “intel” executable
x86_64-linux-gnu-gcc -static -fno-pie -no-pie -ggdb3 -o intel main.c x86/*.s
```

If you want to *just* generate the assembly source (without linking):

```bash
x86_64-linux-gnu-gcc -S -fno-pie -no-pie -masm=intel -o intel.s main.c
```

### IBM / s390x target

```bash
s390x-linux-gnu-gcc -static -fno-pie -no-pie -ggdb3 -o ibm main.c IBM/*.s
```

Or just to generate the assembly:

```bash
s390x-linux-gnu-gcc -S -fno-pie -no-pie -o ibm.s main.c
```

---

## Usage / Running

Once compiled, you can run the resulting executables:

```bash
./intel
./ibm
```

Typically, the program will:

1. generate a random or fixed coefficient matrix and constant vector  
2. call the assembly-implemented solver  
3. output results (solutions or error message)  
4. optionally verify correctness via comparison against C or known solution  

You can customize input size (number of equations), tolerances, etc., by editing `main.c` or passing arguments (if implemented).

