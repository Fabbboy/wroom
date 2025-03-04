.section .note.GNU-stack,"",%progbits
.section .text  
.globl _start
.type _start, @function
_start:
    popq %rdi
    movq %rsp, %rsi
    andq $-16, %rsp
    subq $8, %rsp  
    call main
    addq $8, %rsp
    movq $60, %rax
    xorl %edi, %edi
    syscall

main:
    //jmp .
    ret 