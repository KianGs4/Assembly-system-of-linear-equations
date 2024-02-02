.data
 
.align 2  
  read_int_format:      .asciz  "%d"
.align 2
  read_double_format:   .asciz  "%lf"
.align 32
   mat:           .zero 8008000
.align 32 
   res:           .zero  8000
.align 2
   temp:           .zero 8
.align 2
    resTemp:       .zero 8
.align 2
     zero:         .zero 8

.text 

read_double:    # moves double to f0
        stg     %r14, -8(%r15)
        lay     %r15, -168(%r15)
        larl    %r2,  read_double_format
        brasl   %r14, scanf
        lay     %r15, 168(%r15)
        lg      %r14, -8(%r15)
        br      %r14

print_double:   # print double in f0
        stg     %r14, -8(%r15)
        lay     %r15, -168(%r15)
        larl    %r2,  read_double_format
        brasl   %r14, printf
        lay     %r15, 168(%r15)
        lg      %r14, -8(%r15)
        br      %r14


read_int: #
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lay     %r3,  0(%r15)  
        larl    %r2,  read_int_format
        brasl   %r14, scanf
	l       %r2,  0(%r15)
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14

print_int:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lr      %r3,  %r2
        larl    %r2,  read_int_format
        brasl   %r14, printf
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14

print_space:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
	la      %r2,  32
        brasl   %r14, putchar
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14

print_message:
        stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        la      %r2,  73
        brasl   %r14, putchar
        la      %r2,  109
        brasl   %r14, putchar
        la      %r2,  112
        brasl   %r14, putchar
        la      %r2,  111
        brasl   %r14, putchar        
        la      %r2,  115
        brasl   %r14, putchar
        la      %r2,  115
        brasl   %r14, putchar
        la      %r2,  105
        brasl   %r14, putchar
        la      %r2,  98
        brasl   %r14, putchar
        la      %r2,  108
        brasl   %r14, putchar
        la      %r2,  101
        brasl   %r14, putchar
        lay     %r15, 8(%r15)
        lg      %r14, -4(%r15)
        br      %r14




.global asm_main


asm_main:
	stg %r14, -4(%r15)
	lay %r15, -8(%r15)

        brasl 14,read_int  # r6 -> n
        lr  %r6,%r2
        lr   %r13,%r6
        ahi  %r13,1
        lr   %r2,%r13
        xr  %r7,%r7
outGetLoop:
        lr   %r9,%r7
        mhi  %r9,8000
        xr   %r8,%r8
        xr   %r10,%r10
inGetLoop:
       brasl  14,read_double

       larl  %r1,mat
       ar   %r1,%r9
       ar   %r1,%r10
       std  %f0,0(%r1)

       ahi %r10,8
       ahi %r8,1
       cr  %r8,%r13
       jne inGetLoop

       ahi  %r7,1
       cr   %r7,%r6
       jne  outGetLoop


     xr %r7,%r7
swapOutLoop:
    
    lr  %r8,%r7
    ahi %r8,1
    lr  %r10,%r7
    mhi %r10,8000
    lr  %r13,%r8
    mhi %r13,8000
swapInLoop:
    lr  %r12,%r7
    mhi %r12,8
    cr %r8,%r6
    je endSwapInLoop
#create abs to f0 and f1:
    # f0 <- abs(mat[i][i])
    larl %r1,mat
    ar   %r1,%r10
    ar   %r1,%r12
    ld   %f0,0(%r1)
    larl %r2,zero
    kdb  %f0,0(%r2)
    jnm  contAbs1
    ld   %f0,0(%r2)
    sdb  %f0, 0(%r1)
contAbs1:  
    # f0 <- abs(mat[j][i])
    larl %r1,mat
    ar   %r1,%r12
    ar   %r1,%r13
    ld   %f1,0(%r1)
    larl %r2,zero
    kdb  %f1,0(%r2)
    jnm  contAbs2
    ld   %f1,0(%r2)
    sdb  %f1, 0(%r1)
contAbs2:
    kdbr %f0, %f1
    jnm  notSwapingMode    
    xr %r12,%r12
    xr %r9,%r9
swap_mode:
#   swapping mat[i][k] and mat[j][k]
    larl %r1,mat
    ar   %r1,%r10
    ar   %r1,%r12
    ld   %f0,0(%r1)
    larl %r2,mat
    ar   %r2,%r13
    ar   %r2,%r12
    ld   %f1,0(%r2)
  
    std  %f0,0(%r2)
    std  %f1,0(%r1)

    ahi %r9,1
    ahi %r12,8
    lr %r1,%r6
    ahi %r1,1
    cr %r9,%r1
    jne swap_mode

notSwapingMode:
    ahi %r13,8000
    ahi %r8,1
    j   swapInLoop 
endSwapInLoop:
    ahi %r7,1
    cr  %r7,%r6
    jne swapOutLoop




#    Gaussian elimination 
     xr %r7,%r7
guassianOutLoop:
     lr  %r1,%r6
     ahi %r1,-1
     cr  %r7,%r1
     je  endGaussianLoop
       
     lr  %r10,%r7
     mhi %r10,8000

     lr  %r8,%r7
     ahi %r8,1
     lr  %r13,%r8
     mhi %r13,8000
gaussianInLoop:     
     cr   %r8,%r6
     je   endInsideGaussionLoop 
     
     lr  %r12,%r7 
     mhi %r12,8

     # f0 <- mat[j][i]
     larl %r1,mat 
     ar   %r1,%r13
     ar   %r1,%r12
     ld   %f0,0(%r1)
     # r1 <- mat[i][i]
     larl %r1,mat
     ar   %r1,%r10
     ar   %r1,%r12
     # f0 <- f0/r1
     ddb %f0,0(%r1)
     
     #check r1 != 0 :
     ld  %f2,0(%r1)
     larl %r1,zero
     kdb %f2,0(%r1)
     jne contGaus
     brasl 14,print_message
     j exit
contGaus:      
     # resTemp <- f0
     larl %r1,resTemp
     std  %f0,0(%r1)

    larl %r1,mat
     ar   %r1,%r13
     ar   %r1,%r12
     ld   %f0,0(%r1)

     xr %r9,%r9
     xr %r12,%r12
gaussianAddLoop:
     # r1 <- mat[i][k]
     larl %r1,mat
     ar   %r1,%r10
     ar   %r1,%r12
     #f0 <- resTemp * r1
     larl %r2,resTemp  
     ld   %f0,0(%r2) 
     mdb  %f0,0(%r1) 

     # temp <- f0
     larl %r1,temp
     std  %f0,0(%r1)

     #f0  <- r2 <- mat[j][k]
     larl %r2,mat
     ar   %r2,%r13
     ar   %r2,%r12
     ld   %f0,0(%r2)
 

     #f0 = f0 - temp
     larl %r1,temp
     sdb  %f0,0(%r1)
     std  %f0,0(%r2)     

    
     larl %r2,mat
     ar   %r2,%r13
     ar   %r2,%r12
     ld   %f0,0(%r2)
 

     ahi %r12,8
     ahi %r9,1
     lr  %r1,%r6
     ahi %r1,1
     cr  %r9,%r1
     jne gaussianAddLoop

     ahi  %r8,1
     ahi  %r13,8000
     j    gaussianInLoop
endInsideGaussionLoop:

     ahi %r7,1
     j  guassianOutLoop
endGaussianLoop:

#   Backward substitution 
     lr  %r7,%r6
     ahi %r7,-1
#------





 
backwardOutLoop:
    lr %r9,%r7
    lr %r10,%r7
    mhi %r9,8000
    mhi %r10,8
# res[i] = mat[i][n] 
# mat[i][n] -> f0   
    lr %r2,%r6
    mhi %r2,8
    larl %r1,mat
    ar   %r1,%r9
    ar   %r1,%r2
    ld   %f0,0(%r1)
#f0 -> res[i]
    larl %r1,res
    ar   %r1,%r10
    std  %f0,0(%r1)
   
    
    lr %r8,%r7
    ahi %r8,1
    
    lr  %r13,%r8
    mhi %r13,8
backWardInLoop:
    cr %r8,%r6
    je endBackLoop
# f0 <- res[j]  
    larl  %r2,res
    ar    %r2,%r13
    ld    %f0,0(%r2)
# f0 <- f0 * mat[i][j]
   larl %r1,mat
   ar   %r1,%r9
   ar   %r1,%r13
   mdb %f0, 0(%r1) 
#  temp <- f0
   larl %r1,temp
   std  %f0,0(%r1)
# f0 <- res[i] - temp
    larl  %r2,res
    ar    %r2,%r10
    ld    %f0,0(%r2)
    larl  %r1,temp
    sdb   %f0,0(%r1)
# res[i] <- f0
    std    %f0,0(%r2)

    ahi %r8,1
    ahi %r13,8
    j backWardInLoop
endBackLoop: 
# res[i] = res[i]/mat[i][i]
# r1 <- mat[i][i]
     larl  %r1,mat
     ar    %r1,%r9
     ar    %r1,%r10
 #check r1 != 0 :
     ld  %f2,0(%r1)
     larl %r2,zero
     kdb %f2,0(%r2)
     jne contBackW
     brasl 14,print_message
     j exit
contBackW:
# f0 <- res[i]
    larl  %r2,res
    ar    %r2,%r10
    ld   %f0,0(%r2)
 
    ddb  %f0,0(%r1)
    std   %f0,0(%r2)
    
    ahi %r7,-1
    chi %r7,-1
    jne  backwardOutLoop




# print result 
   xr %r7,%r7
   xr %r8,%r8
printLoop:
   larl %r1,res 
   ar   %r1,%r8
   ld   %f0,0(%r1)
   brasl 14,print_double
   brasl 14,print_space
   ahi %r8,8
   ahi %r7,1
   cr  %r7,%r6
   jne printLoop


exit:

	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14
        
  
