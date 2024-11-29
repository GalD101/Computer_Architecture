.section .text

// .global pstrlen
// .type pstrlen, @function
// pstrlen:
//     # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
//     pushq	%rbp                    # save the old frame pointer
//     movq	%rsp,	%rbp	        # create the new frame pointer

//     xorb    %cl, %cl                # clear %cl, which we will use as a counter.
    
//     pstrlen_loop:
//         # check every character in sequence
//         # ;if null byte - quit the loop, otherwise - increment counter by 1
//         cmpb    (%rdi, %rcx, 1), $0 # %rdi + 1*%cl
//         je      end_loop
//         incb    %cl
//         jmp pstrlen_loop

//     end_loop:
//         movb %cl, %al               # TODO: Check this, I need to return a byte long answer (char) of the length


//     movq    %rbp, %rsp              # close pstrlen activation frame
//     popq    %rbp                    # restore activation frame
//     ret

.global swapCase
.type swapCase, @function
swapCase:
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    xorb    %cl, %cl                # set %cl to 0, which we will use as a counter.
    
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
        movb    1(%rdi, %rcx, 1), %al # this is the current character
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


