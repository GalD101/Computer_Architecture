.section .data
format: .asciz "First LEA result: %ld\nSecond LEA result: %ld\n"

.section .text
.globl main
.type main, @function 
main:
    pushq %rbp
    movq  %rsp, %rbp

    # Zeroing registers
    xorq %rax, %rax
    xorq %rbx, %rbx
    xorq %rcx, %rcx

    # First lea example
    movq $0x1, %rax
    movq $0x2, %rbx
    leaq 5(%rax,%rbx,4), %rcx
    pushq %rcx           # Save first result

    # Second lea example
    movq $0x2, %rax
    movq $0x3, %rbx
    leaq 7(,%rbx,1), %rcx
    pushq %rcx           # Save second result

    # Print results
    movq $format, %rdi
    popq %rdx           # Second result
    popq %rsi           # First result
    xorq %rax, %rax
    call printf

    popq %rbp
    ret
