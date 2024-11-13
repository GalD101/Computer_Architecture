.section .data
format: .asciz "Zero extended: 0x%lx\nSign extended: 0x%lx\n"

.section .text
.globl main
.type main, @function 
main:
    pushq %rbp
    movq  %rsp, %rbp

    # Zero registers
    xorq %rax, %rax
    xorq %rbx, %rbx
    xorq %rdx, %rdx

    # Sign extend vs. Zero extend
    movb  $0xFF, %bl
    movzbq %bl, %rdx    # Zero extend
    movsbq %bl, %rax    # Sign extend

    # Save registers for printf
    pushq %rax
    pushq %rdx

    # Call printf
    movq $format, %rdi
    popq %rsi          # Zero extended value
    popq %rdx          # Sign extended value
    xorq %rax, %rax    # Clear AL (number of vector registers used)
    call printf

    popq %rbp
    ret
