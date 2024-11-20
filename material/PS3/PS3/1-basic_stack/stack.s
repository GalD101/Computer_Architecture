.section .text
.globl main
main:
    # Load values into %rax and %rbx
    movq $0xFFFFFFFFFFFFFFFF, %rax
    movq $0xAAAAAAAAAAAAAAAA, %rbx

    # Swap values using push and pop
    push %rax
    push %rbx
    pop %rax
    pop %rbx

    # Allocate 16 bytes on stack
    sub $0x10, %rsp

    # Write the value "0xff" to each of the 16 bytes
    movq %rsp, %rdi
    xorq %rcx, %rcx
.loop:
    movb $0xaa, (%rdi)
    inc %rdi
    inc %rcx
    cmp $0x10, %rcx
    jne .loop

    # "Free" the 16 bytes on stack
    add $0x10, %rsp
    
    # return
    ret
