.section .data
format: .asciz "Signed comparison result: %ld\nUnsigned comparison result: %ld\n"

.section .text
.globl main
.type main, @function 
main:
    pushq %rbp
    movq  %rsp, %rbp

    # First signed comparison
    xorq %rax, %rax
    xorq %rbx, %rbx
    movb $0xff, %al
    movb $0x0f, %bl
    
    cmpb %al, %bl
    jg  signed_greater
    jl  signed_less
    
signed_greater:
    movq $1, %r12
    jmp unsigned_test
    
signed_less:
    movq $2, %r12
    
unsigned_test:
    # Now unsigned comparison
    xorq %rax, %rax
    xorq %rbx, %rbx
    movb $0xff, %al
    movb $0x0f, %bl
    
    cmpb %al, %bl
    ja  unsigned_above
    jb  unsigned_below
    
unsigned_above:
    movq $1, %r13
    jmp print_results
    
unsigned_below:
    movq $2, %r13
    
print_results:
    # Print results
    movq $format, %rdi
    movq %r12, %rsi      # Signed result
    movq %r13, %rdx      # Unsigned result
    xorq %rax, %rax
    call printf

    popq %rbp
    ret
