
%macro stack_alignment 0
	 push rbp
	mov rbp, rsp
	mov rax, rsp
	and rax, 15
	sub rsp, rax
%endmacro


%macro stack_alignment_done 0
     mov rsp, rbp
    pop rbp
%endmacro 


segment .bss 
mat:  resb 8008000
res:  resb 8000

segment .data  
temp:  dq 0.0
zero:  dq 0.0
minus: dq -1.0 
read_int_format:    db "%ld", 0
float_format:                db "%lf", 0
print_int_format: db        "%ld", 0
message:           db  'Impossible', 10
messageLen:       equ $-message 


segment .text

extern printf
extern scanf
extern puts
extern putchar
global asm_main

;functions: 


read_int:
    stack_alignment 

    sub rsp, 16
    mov rsi, rsp
    mov rdi, read_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf

    mov rax, [rsp]


    stack_alignment_done
    ret

print_int:
    stack_alignment

    mov rsi, rdi
    mov rdi, print_int_format
    mov rax, 1 ;  setting rax (al) to number of vector inputs
    call printf
    
    stack_alignment_done

    ret

read_float:
   stack_alignment 
  
   sub rsp,16
   mov rdi,float_format
   mov rsi,temp
   mov rax,0
   call scanf     
   movq  xmm0,[temp]

   stack_alignment_done

    ret

print_float:
   stack_alignment 

    ;in float point mode xmm0 holds the value to be printed
    mov rdi, float_format
    mov rax, 1 ;rax has to be set 1 to float point mode
    call printf

    stack_alignment_done

    ret


print_space:
   stack_alignment
    mov rdi,' ' 
    call putchar

    stack_alignment_done

    ret

print_message:
   stack_alignment
 
    mov eax,4            ; 'write' system call = 4
    mov ebx,1            ; file descriptor 1 = STDOUT
    mov ecx,message      ; string to write
    mov edx,messageLen     ; length of string to write
    int 80h              ; call the kernel

    stack_alignment_done

    ret

checkSwap:  ;r13 and r14 -> inputs ; output: r15: 1(swapping)
   mov  r15,0
   mov  rbx,r13
   imul rbx,8000
   mov  rdx,r14
   imul rdx,8000
   mov  r9,r13
   imul r9,8
;abs(mat1):
   movq    xmm0,[mat + rbx + r9] 
   comisd xmm0,[zero]
   jge    abs1
   mulsd  xmm0,[minus] 
abs1:
;abs(mat2):
   movq    xmm1,[mat + rdx + r9]
   comisd xmm1,[zero]
   jge    abs2
   mulsd  xmm1,[minus]
abs2:
  subsd  xmm0,xmm1
  comisd  xmm0,[zero]
  jae  swapEnd 
  mov r15,1
swapEnd:
   ret   


asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
   
    sub rsp, 8

    call  read_int 
    mov   r12,rax ; no. of equations
    mov   rcx,rax
    
; give Coefficient and sum of each equation and reserve it in mat n * n+1
   mov r13,r12
   inc r13
   mov r14,0 ; -> 1d index
   mov r15,0 ; -> 2d index
outLoop:   
   push r13
   push rcx
insideLoop:
    call read_float 
    movq [mat + r14 + r15],xmm0
    add r15,8 
    dec r13 
    cmp r13,0 
    jne insideLoop
    pop rcx
    pop r13
    add r14,8000
    mov r15,0
    loop outLoop


;ordering rows: 
  mov r13,0
outRowLoop: 
  mov r14,r13
  inc r14 
inRowLoop: 
   cmp r14,r12
   je  contInRowLoop
   call checkSwap
   cmp r15,1
   jne notSwapping
   mov rbx,r13
   imul rbx,8000
   mov rdx,r14
   imul rdx,8000

   xor r15,r15
   mov r10,0
   mov r8,r12
   inc r8
swapRowLoop:
 ;  swapping mat[r13][r15] and mat[r14][r15]
   movq xmm0,[mat + rbx + r10]
   movq xmm1,[mat + rdx + r10]
   movq [mat + rbx + r10],xmm1
   movq [mat + rdx + r10],xmm0
   add r10,8
   inc r15  
   cmp r15,r8
   jne swapRowLoop

notSwapping:
   inc r14
   jmp inRowLoop
contInRowLoop:
   inc r13
   cmp r13,r12
   jne outRowLoop

;Gaussian elimination
   mov r13,0
outLoop1:
   mov r8,r12
   dec r8
   cmp r13,r8
   je  backwardSubs 

   mov r14,r13
   inc r14
   mov rbx,r13
   imul rbx,8000
   mov rdx,r13
   imul rdx,8
fInLoop: 
   cmp    r14,r12
   je     endLoop1 
   movq   xmm0,[mat + rbx + rdx] 
   comisd xmm0,[zero]
   jne   contLoop
   call  print_message 
   jmp   exit 
contLoop:
  mov  r10,r14
  imul r10,8000
  movq  xmm0,[mat + r10 + rdx]
  divsd xmm0,[mat + rbx + rdx]
  mov r15,0
  mov r11,0
LInLoop:
  movq  xmm1,[mat + r10 + r11] 
  movq xmm2,[mat + rbx +  r11]
  mulsd xmm2,xmm0
  subsd xmm1,xmm2
  movq  [mat + r10 + r11],xmm1
  add r11,8   
  inc r15
  mov r8,r12
  inc r8
  cmp r15,r8
  jne LInLoop

  inc r14
  cmp r14,r12
  jne fInLoop 

endLoop1:
  inc r13
  jmp  outLoop1


backwardSubs:

;  Backward substitution for finding each variable
   mov r13,r12
   dec r13
outLoop2:  
   mov r11,r13
   imul r11,8000
   mov r15,r13
   imul r15,8

   push r12
   imul r12,8
   movq xmm0,[mat + r11  + r12]
   pop  r12

   movq [res + r15],xmm0
   mov r14,r13
   inc r14
   
   push r15
   movq xmm0,[res + r15]
   add r15,8

insideLoop2:
   cmp r14,r12
   je  endLoop2
   movq xmm1,[res + r15]
   movq xmm2,[mat + r11  + r15]
   mulsd xmm1,xmm2
   subsd xmm0,xmm1
    add r15,8
    inc r14
    jmp insideLoop2
endLoop2:
   pop r15
   movq xmm2,[mat + r11 + r15]
   comisd xmm2,[zero]
   jne acceptCheck
   call print_message
   jmp exit
acceptCheck:
   divsd xmm0,[mat + r11  + r15]
   movq [res + r15], xmm0
   dec r13
   cmp r13,-1
   jne outLoop2


;printing result
mov rcx,r12
mov r13,0

printLoop:
   push rcx
   movq xmm0,[res + r13]
   call print_float
   call print_space
   pop rcx
   add r13,8
   loop printLoop 


exit:
        add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret
