.extern printf

.section .rodata

invalid_inpt_msg:          .string "invalid input!\n"
too_long_msg:              .string "cannot concatenate strings!\n"

.section .text

.global pstrlen
.type pstrlen, @function
pstrlen:
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,   %rbp        # create the new frame pointer

    # I assume that the len property will always be correct and thus I don't have to iterate letter by letter and counting until reaching a null byte.
    movb  (%rdi), %al           # Load the length byte into %al

    movq    %rbp, %rsp          # close pstrlen activation frame
    popq    %rbp                # restore activation frame
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
        cmpb    $25, %al              # 90 - 65 = 25 and according to the formula, (unsigned)(number-65) <= (122-65)
        jbe     upper_to_lower        # use jbe (jump below equal) for unsigned comparisons
        
        # ;if we reached here, the character is not a letter, simply skip it
        incb    %cl                   # move to the next character
        jmp     swapCase_loop         # jump to the beginning of the loop

    lower_to_upper:
        movb    1(%rdi, %rcx, 1), %al # save the current letter to this register so I won't modify the original value
        subb    $32, %al              # %al = %al - 32
        movb    %al, 1(%rdi, %rcx, 1) # save the new value to the string
        incb    %cl                   # move to the next character
        jmp     swapCase_loop         # jump to the beginning of the loop

    upper_to_lower:
        movb    1(%rdi, %rcx, 1), %al # save this to this register so I won't modify the original value
        addb    $32, %al              # %al = %al + 32
        movb    %al, 1(%rdi, %rcx, 1) # save the new value to the string
        incb    %cl                   # move to the next character
        jmp     swapCase_loop         # jump to the beginning of the loop

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

    subq    $16, %rsp               # allocate space to save pointer to dst (has to be 16 aligned)
    movq    %rdi, -16(%rbp)         # save pointer to dst

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
    # cmovb only works for 16 bit registers and higher :( that's why I need to use r10w and r11w instead of the smaller r10b and r11b
    cmpb    %r10b, %r11b
    cmovb   %r11w, %r10w             # suppose dst(src) is shorter, if it is not shorter then src(dst) must be shorter.
    cmpb    %r10b, %cl               # check that j < min(len of src, len of dst) <==> !(j >= min(len of src, len of dst))
    jae     invalid_input_pstrijcpy

    leaq    1(%rsi, %rdx, 1), %r8   # calculate the i'th letter address in src
    leaq    1(%rsi, %rcx, 1), %r9   # calculate the j'th letter address in src

    leaq    1(%rdi, %rdx, 1), %r10  # calculate the i'th letter address in dst
    
    # calculate j - i + 1 (number of iterations because we include i and j when copying)
    subb    %dl, %cl            # calculate j - i
    incb    %cl                 # add 1 to j - i

    loop_copy_pstrijcpy:
        # Copy a byte from the memory location pointed to by %r8 to the memory location pointed to by %r10.
        # Then increments the byte pointers %r8 and %r10.
        # The loop continues until the value in %r8 is greater than the value in %r9.
        # the last line shouldn't be the way we terminate the loop (this is what I tried but I had an infinite loop)
        # Consider this input: 64, "kjZmjYxquhmSQlUZDIGo0JpCuTV8XpqeP049HWFoS77Vm6v3GsJejLnARXezitr7" and 243, "UVSm7R9YUprndZ1CHliu39w9mHR5P9zvA6WLxQrmuwbHpN6TsL5YkDOBNXTnlCy13wdGZM94fX2FzEA2LTRgPC0dRHwerQfjOdJfIBgRqwhUfGzbD4lv82MQ8oL9bp2iBqJjx59kwTbs5db7tUwKqxBbLHJnoDdOSkMg5zxjo4jZrcQ9KN7g3hLhYw9QlWzFQHpu4lYgYOIHtDEzQ3zO8Tef8XHOkwoulQou6X2NUKTBOBfZqQj"
        # this causes an infinite loop.
        # the other way to terminate the loop is using a counter that exits after j - i + 1 iterations.

        # here is a nice epitome of the way computer stores strings as opposed to other values (just a string in the natural order vs little endian)
        # this is why I need to copy to a register and then copy to another register (kind of like moving from stack to stack I reverse the order. P.S. I actually had a question about this in my bagrut)
        movb    (%r8), %al          # load the byte at the address stored in %r8 into %al
        movb    %al, (%r10)         # store this byte in %al at the address in %r10
        incb    %r8b                # move the current i in dst by 1
        incb    %r10b               # move the current i in src by 1

        decb    %cl                 # decrease the counter
        jnz     loop_copy_pstrijcpy # if the counter is not 0, continue copying


        # below is deprecated code (causes an infinite loop, I included so that I will know to watch out from this in the future):
        # cmpq    %r9, %r8            # if the address of the cur_i letter in src equals the address of the j'th letter in src
        # jbe     loop_copy_pstrijcpy

    epilogue_pstrijcpy:
        movq    -16(%rbp), %rax     # restore pointer to dst (it won't change, but the value it holds in the address it points to might)
        movq    %rbp, %rsp          # close pstrijcpy activation frame
        popq    %rbp                # restore activation frame
        ret

    invalid_input_pstrijcpy:
        movq    $invalid_inpt_msg, %rdi # load the text to first argument
        xorb    %al, %al                # clear %al before function call (customary)
        call    printf                  # printf(invalid_inpt_msg);
        jmp epilogue_pstrijcpy          # end function



.global pstrcat
.type pstrcat, @function
pstrcat: # Pstring* pstrcat(Pstring* dst, Pstring* src);
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    subq    $16, %rsp               # allocate space to save pointer to dst (has to be 16 aligned)
    movq    %rdi, -16(%rbp)         # save pointer to dst

    # %rdi is dst, %rsi is src
    # dst->len + src->len --> dst->len

    # save len in caller saved registers:
    movq    %rdi, %rax              # save pointer to dst in %rax
    movzbw  (%rax), %r10w           # load length of dst into the lower part of %r10
    movq    %rsi, %rax              # save pointer to src in %rax
    movzbw  (%rax), %r11w           # load length of src into the lower part of %r11

    # so now %r10w holds the length of dst and %r11w holds the length of src
    # %r10w = dst->len, %r11w = src->len

    # calculate the length of the new string
    addb    %r10b, %r11b              # %r11 = %r11 + %r10
    jc      too_long                  # If Carry Flag (CF) is set, sum > 255

    # check if the new string is too long (it is exactly 255 characters long)
    cmpb    $255, %r11b               # check if %r11 = 255. %r11 is the new len of dst and will be updated after copying
    je      too_long                  # above because len is unsigned

    xorq    %rcx, %rcx                # set %rcx to 0, we will use it as a counter.
    movzbw  (%rsi), %r11w             # load length of src into the lower part of %r11 (again)

    # calculate the address of the end of the dst string
    movzbq  %r10b, %rax               # move the length of dst to %rax
    xorq    %r10, %r10                # clear %r10
    movb    %al, %r10b                # move the length of dst to %r10b
    leaq    1(%rdi, %r10, 1), %r10    # calculate the address of the end of the dst string, save in %r10

    loop_copy_pstrcat:
        # copy the current character of src to the end of dst (r10)
        movb    1(%rsi, %rcx, 1), %al         # load the byte at the address in %rsi into %al
        movb    %al, (%r10, %rcx, 1)          # store the byte in %al at the address in %r10
        incb    %cl                           # move to the next character in src
        cmpb    %r11b, %cl                    # check if we finished copyings all the characters in src
        jnz     loop_copy_pstrcat             # if we didn't, continue copying

    
    movb (%rdi), %al       # load the first byte at address stored in %rdi into %al
    addb %cl, %al          # add the value in %cl to %al
    movb %al, (%rdi)       # store the result back to the the value %rdi points to


    epilogue_pstrcat:
        movq    -16(%rbp), %rax     # restore pointer to dst (it won't change but the value it holds in the address it points to might)
        movq    %rbp, %rsp          # close pstrijcpy activation frame
        popq    %rbp                # restore activation frame
        ret


    too_long:
        movq    $too_long_msg, %rdi # load the text to first argument
        xorb     %al, %al           # clear %al before function call (customary)
        call    printf              # printf(too_long_msg);
        jmp epilogue_pstrcat        # end function
