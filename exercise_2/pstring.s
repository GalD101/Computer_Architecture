# TODOOOOO !!!!!!!!!!!!!!!!!!
# USE THE STACK INSTEAD OF REGISTERS LIKE R8 AND R9 OR MAYBE NOT????
.extern printf

.section .rodata

invalid_inpt_msg:          .string "invalid input!\n"
too_long_msg:              .string "cannot concatenate strings!\n"


.section .text

.global pstrlen
.type pstrlen, @function
# TODO: MAYBE IT IS BETTER TO SIMPLY RETURN THE LEN PROPERTY I.E. %rdi + 1
pstrlen:
    pushq   %rbp
    movq    %rsp,   %rbp

    movzbl  (%rdi), %eax  # Load the length byte into %eax

    movq    %rbp, %rsp
    popq    %rbp
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

    subq    $16, %rsp
    movq    %rdi, -16(%rbp)    # save pointer to dst
    # %rdi is dst, %rsi is src, %dl is i, %cl is j
    # src[i, j] -> dst[i, j]

    # check that i <= j <==> !(i > j)
    cmpb    %cl, %dl
    ja      invalid_input_pstrijcpy

    # save len in caller saved registers:
    movzbw    (%rdi), %r10w           # load length of dst into the lower part of %r10
    movzbw    (%rsi), %r11w           # load length of src into the lower part of %r11

    # calculate min(len of src, len of dst)
    # cool trick to implement min(or max) function: https://stackoverflow.com/questions/42760054/assembly-find-max-of-two-value
    # cmovb only works for 16 bit registers and higher :( that's why I need to use r10e and r11w instead of the smaller r10b and r11b
    cmpb    %r10b, %r11b
    cmovb   %r11w, %r10w             # suppose dst(src) is shorter, if it is not shorter then src(dst) must be shorter.
    cmpb    %r10b, %cl               # check that j < min(len of src, len of dst) <==> !(j >= min(len of src, len of dst))
    jae     invalid_input_pstrijcpy

    # calculate the i'th letter address in src
    leaq    1(%rsi, %rdx, 1), %r8
    # calculate the j'th letter address in src
    leaq    1(%rsi, %rcx, 1), %r9
    
    # calculate the i'th letter address in dst
    leaq    1(%rdi, %rdx, 1), %r10
    loop_copy_pstrijcpy:
        // This code snippet copies a byte from the memory location pointed to by %r8 to the memory location pointed to by %r10.
        // It then increments the byte pointers %r8 and %r10.
        // The loop continues until the value in %r8 is greater than the value in %r9.
        movb    (%r8), %al          # load the byte at the address in %r8 into %al
        movb    %al, (%r10)         # store the byte in %al at the address in %r10
        incb    %r8b                # move the current i in dst by 1
        incb    %r10b               # move the current i in src by 1
        cmpq    %r9, %r8            # if the address of the cur_i letter in src equals the address of the j'th letter in src
        jbe     loop_copy_pstrijcpy
        # What's next? IDK????!!!!!
        #1 copy the val at r10b to cur_i letter in dst
        #2 increase i by 1
        #3 calculate the next letter in src and save in r10b
        #4 if i < j go to 1 if i == j finish



    epilogue_pstrijcpy:
        movq    -16(%rbp), %rax     # restore pointer to dst (it won't change but the value it holds in the address it points to might)
        movq    %rbp, %rsp          # close pstrijcpy activation frame
        popq    %rbp                # restore activation frame
        ret

    invalid_input_pstrijcpy:
        movq    $invalid_inpt_msg, %rdi
        xor     %rax, %rax
        call    printf
        jmp epilogue_pstrijcpy



.global pstrcat
.type pstrcat, @function
pstrcat:
    # TODO MAKE SURE THAT YOU DON'T MODIFY ANYTHING IN SRC!!!!
    # REMEMBER TO UPDATE THE LEN OF DST!!!!
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    subq    $16, %rsp
    movq    %rdi, -16(%rbp)    # save pointer to dst
    # %rdi is dst, %rsi is src
    # dst + src -> dst

    # save len in caller saved registers:
    movq    %rdi, %rax
    movzbw  (%rax), %r10w           # load length of dst into the lower part of %r10
    movq    %rsi, %rax
    movzbw  (%rax), %r11w           # load length of src into the lower part of %r11

    # calculate the length of the new string
    addb    %r10b, %r11b              # %r11 = %r11 + %r10
    jc      too_long                  # If Carry Flag (CF) is set, sum > 255

    # check if the new string is too long (it is exactly 255 characters long)
    cmpb    $255, %r11b               # check if %r11 = 255. %r11 is the new len of dst and will be updated after copying
    je      too_long                  # above because len is unsigned

    xorq    %rcx, %rcx                # set %rcx to 0, we will use it as a counter.
    movzbw  (%rsi), %r11w             # load length of src into the lower part of %r11 (again)

    # calculate the address of the end of the dst string
    movzbq  %r10b, %rax
    xorq    %r10, %r10
    movb    %al, %r10b
    leaq    1(%rdi, %r10, 1), %r10

    loop_copy_pstrcat:
        # copy the current character of src to the end of dst (r10)
        movb    1(%rsi, %rcx, 1), %al         # load the byte at the address in %rsi into %al
        movb    %al, (%r10, %rcx, 1)          # store the byte in %al at the address in %r10
        incb    %cl
        cmpb    %r11b, %cl                    # check if we finished copyings all the characters in src
        jnz     loop_copy_pstrcat

    
    movb (%rdi), %al       # Load the first byte at address [%rdi] into %al
    addb %cl, %al          # Add the value in %cl to %al
    movb %al, (%rdi)       # Store the result back to the memory location [%rdi]


    epilogue_pstrcat:
        movq    -16(%rbp), %rax     # restore pointer to dst (it won't change but the value it holds in the address it points to might)
        movq    %rbp, %rsp          # close pstrijcpy activation frame
        popq    %rbp                # restore activation frame
        ret


    too_long:
        movq    $too_long_msg, %rdi
        xor     %rax, %rax
        call    printf
        jmp epilogue_pstrcat
