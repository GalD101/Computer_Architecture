.extern printf

// .section .rodata

// invalid_inpt_msg:          .string "invalid input!\n"


.section .text

.global pstrlen
.type pstrlen, @function
# TODO: MAYBE IT IS BETTER TO SIMPLY RETURN THE LEN PROPERTY I.E. %rdi + 1
pstrlen:
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    xorb    %cl, %cl                # clear %cl, which we will use as a counter.
    
    pstrlen_loop:
        # check every character in sequence
        # ;if null byte - quit the loop, otherwise - increment counter by 1
        cmpb    $0, 1(%rdi, %rcx, 1) # %rdi + 1*%cl
        je      end_loop
        incb    %cl
        jmp pstrlen_loop

    end_loop:
        movb %cl, %al               # TODO: Check this, I need to return a byte long answer (char) of the length


    movq    %rbp, %rsp              # close pstrlen activation frame
    popq    %rbp                    # restore activation frame
    ret

.global swapCase
.type swapCase, @function
swapCase:
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    xorq    %rcx, %rcx                # set %rcx to 0, we will use its lower 8 part (%cl) as a counter.
    
    swapCase_loop:
        # Load the length of the Pstring into %bl
        movb    (%rdi), %bl             # load length byte into %bl
        # check if we reached the end of the string
        cmpb    %cl, %bl                # check if %cl == %rdi which is if counter == Pstring->len
        je      end_swapCase

        # check every character in sequence
        # ;if it is a character, change its case
        # check if this is a lower case letter
        # use this formula to check if character is in range
        # ;if ((unsigned)(number-lower) <= (upper-lower)) {number is in range}
        # found on https://stackoverflow.com/questions/17095324/fastest-way-to-determine-if-an-integer-is-between-two-integers-inclusive-with

        # Check if the current character is a lowercase letter
        # %rdi + 1 is the pointer to the first character in the string
        # %rdi + 1 + %rcx is the pointer to the current character
        movb    1(%rdi, %rcx, 1), %al # this is the current character (%rdi + 1) + 1*%rcx (I can't use %cl here so I have to use the entire %rcx)
        subb    $97, %al              # %al = %al - 97 (character - 'a')
        cmpb    $25, %al              # 122 - 97 = 25 and according to the formula, (unsigned)(number-97) <= (122-97)
        jbe     lower_to_upper        # use jbe (jump below equal) for unsigned comparisons
        
        # Check if the current character is an uppercase letter
        movb    1(%rdi, %rcx, 1), %al # save this to this register so I won't modify the original value
        subb    $65, %al              # %al = %al - 65 (character - 'A')
        cmpb    $25, %al              # 90 - 65 = 25 and according to the formula, (unsigned)(number-65) <= (122-97)
        jbe     upper_to_lower        # use jbe (jump below equal) for unsigned comparisons
        
        # ;if we reached here, the character is not a letter, simply skip it
        incb    %cl
        jmp     swapCase_loop

    lower_to_upper:
        movb    1(%rdi, %rcx, 1), %al # save this to this register so I won't modify the original value
        subb    $32, %al              # %al = %al - 32
        movb    %al, 1(%rdi, %rcx, 1) # save the new value to the string
        incb    %cl
        jmp     swapCase_loop
    upper_to_lower:
        movb    1(%rdi, %rcx, 1), %al # save this to this register so I won't modify the original value
        addb    $32, %al              # %al = %al + 32
        movb    %al, 1(%rdi, %rcx, 1) # save the new value to the string
        incb    %cl
        jmp     swapCase_loop
    end_swapCase:
        movq    %rdi, %rax              # return the pointer to the string
        movq    %rbp, %rsp              # close swapCase activation frame
        popq    %rbp                    # restore activation frame
        ret


.global pstrijcpy
.type pstrijcpy, @function
pstrijcpy:
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    # %rdi is dst, %rsi is src, %dl is i, %cl is j
    # src[i, j] -> dst[i, j]

    # check that i <= j <==> !(i > j)
    cmpb    %cl, %dl
    ja      invalid_input

    # save len in caller saved registers:
    movzbw    (%rdi), %r10w           # load length of dst into the lower part of %r10
    movzbw    (%rsi), %r11w           # load length of src into the lower part of %r11

    # calculate min(len of src, len of dst)
    # cool trick to implement min(or max) function: https://stackoverflow.com/questions/42760054/assembly-find-max-of-two-value
    # cmovb only works for 16 bit registers and higher :( that's why I need to use r10e and r11w instead of the smaller r10b and r11b
    cmpb    %r10b, %r11b
    cmovb   %r11w, %r10w             # suppose dst(src) is shorter, if it is not shorter then src(dst) must be shorter.
    cmpb    %r10b, %cl               # check that j < min(len of src, len of dst) <==> !(j >= min(len of src, len of dst))
    jae     invalid_input

    # calculate the i'th letter address in src
    leaq    1(%rsi, %rdx, 1), %r8
    # calculate the j'th letter address in src
    leaq    1(%rsi, %rcx, 1), %r9
    
    # calculate the i'th letter address in dst
    leaq    1(%rdi, %rdx, 1), %r10
    loop_copy:
        // This code snippet copies a byte from the memory location pointed to by %r8 to the memory location pointed to by %r10.
        // It then increments the byte pointers %r8 and %r10.
        // The loop continues until the value in %r8 is greater than the value in %r9.
        movb    (%r8), %al          # load the byte at the address in %r8 into %al
        movb    %al, (%r10)         # store the byte in %al at the address in %r10
        incb    %r8b                # move the current i in dst by 1
        incb    %r10b               # move the current i in src by 1
        cmpq    %r9, %r8            # if the address of the cur_i letter in src equals the address of the j'th letter in src
        jbe     loop_copy
        # What's next?
        #1 copy the val at r10b to cur_i letter in dst
        #2 increase i by 1
        #3 calculate the next letter in src and save in r10b
        #4 if i < j go to 1 if i == j finish



    epilogue:
        movq    %rdi, %rax          # return the pointer to the string
        movq    %rbp, %rsp          # close pstrijcpy activation frame
        popq    %rbp                # restore activation frame
        ret

    invalid_input:
    # TODO
        movq    $'L', %rdi
        xor     %rax, %rax
        call    printf
        xorq    %rax, %rax
        jmp epilogue
