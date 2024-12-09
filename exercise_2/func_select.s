.section		      .rodata
choise_31_txt:        .string "first pstring length: %d, second pstring length: %d\n"
choise_33_34_37_txt:  .string "length: %d, string: %s\n"
invalid_option_txt:   .string "invalid option!\n"
invalid_inpt_txt:     .string "invalid input!\n"

fmt_scan_ij:          .string " %hhu %hhu"

.align 8                        # Align address to multiple of 8
switch_choice_jmp_tbl:
.quad   choice_31               # 31 - valid option
.quad   invalid_option          # 32 - invalid option
.quad   choice_33               # 33 - valid option
.quad   choice_34               # 34 - valid option
.quad   invalid_option          # 35 - invalid option
.quad   invalid_option          # 36 - invalid option
.quad   choice_37               # 37 - valid option
                                # anything else is an invalid choice

.section    .text

.globl run_func
.type run_func, @function
run_func: # void run_func(int choice, Pstring *pstr1, Pstring *pstr2);
    # %rdi = choice (int so use %edi), %rsi = &pstr1, %rdx = &pstr2 (both are pointers so use 64 bit registers since this is an address)

    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    subq    $16, %rsp               # create space on the stack for local variables

    leal    -31(%edi), %eax         # "normalize" the choice
    cmpl    $6, %eax                # check if the number is out of the rage 31 - 37 (because 37 - 31 = 6)
    ja      invalid_option          # jump if the choice is outside the range (may still be invalid for 32, 35, 36)
    jmp     *switch_choice_jmp_tbl(,%eax,8) # jump to the right section using a jump table very similar to what we saw in recitation

    choice_31: # will call pstrlen for both Pstrings
    movq   %rdx, -16(%rbp)          # save pointer to pstr2

    movq    %rsi, %rdi              # set pstr1 as the first argument
    xorb    %al, %al                # clear %al before function call (customary)
    call    pstrlen                 # pstrlen(&pstr1);

    movq    %rax, -8(%rbp)          # save the returned length from pstrlen(&pstr1) in the stack
    movq    -16(%rbp), %rdi         # restore the pointer to pstr2 to %rdi (we will use this as a first argument)
    xorb    %al, %al                # clear %al before function call (customary)
    call    pstrlen                 # pstrlen(&pstr1);
    movzb   %al, %rdx               # save the returned length from pstrlen(&pstr2) in %rdx as a third argument for the next call
    movq    $choise_31_txt, %rdi    # load the text to first argument
    movq    -8(%rbp), %rsi          # retore the returned length from pstrlen(&pstr1) from the stack
    xorb    %al, %al                # clear %al before function call (customary)
    call    printf                  # printf(choice_31_txt, pstrlen(&pstr1), pstrlen(&pstr2));
    jmp     end_run_func            # end function

    choice_33: # will call swapCase for both Pstrings
    movq   %rdx, -16(%rbp)          # save pointer to pstr2

    movq    %rsi, %rdi              # set pstr1 as the first argument
    xorb    %al, %al                # clear %al before function call (customary)
    call    swapCase                # swapCase(&pstr1);

    movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
    movzb   (%rax), %rsi                # load the length of the returned Pstring from swapCase as a second argument
    leaq    1(%rax), %rdx               # copy the address of the string that is stored in the Pstring returned from swapCase
    xorb    %al, %al                    # clear %al before function call (customary)
    call    printf                      # printf(choice_33_34_37_txt, swapCase(&pstr1)->len, swapCase(&pstr1)->str);

    movq    -16(%rbp), %rdi             # restore the pointer to pstr2 to %rdi (we will use this as a first argument)
    xorb    %al, %al                    # clear %al before function call (customary)
    call    swapCase                    # swapCase(&pstr1);
    movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
    movzb   (%rax), %rsi                # set the returned length from swapCase as a second argument
    leaq    1(%rax), %rdx               # set the address of the returned str from swapCase as a third argument
    xorb    %al, %al                    # clear %al before function call (customary)
    call    printf                      # printf(choice_33_34_37_txt, swapCase(&pstr2)->len, swapCase(&pstr2)->str);
    jmp     end_run_func                # end function

    choice_34: # will call pstrij with both Pstrings and extra user input
    subq    $16, %rsp                   # allocate 16 more bytes in the stack for saving the additional variables i & j
    movb    $0, -16(%rbp)               # Initialize i to 0
    movb    $0, -15(%rbp)               # Initialize j to 0
    movq    %rdx, -32(%rbp)             # save pointer to pstr2
    movq    %rsi, -24(%rbp)             # save pointer to pstr1

    # scan i & j from the user
    movq    $fmt_scan_ij, %rdi          # set the format as the first input for scanf (use 8 bytes (rdi and not e.g. edi) for scanf because man page shows signature for scanf that shows that first&second arguments are char* and in 64-bit architecture this is 8 bytes)
    leaq    -16(%rbp), %rsi             # set the address of i as a second argument
    leaq    -15(%rbp), %rdx             # set the address of j as a third argument
    xorb    %al, %al                    # clear %al before function call (customary)
    call    scanf                       # scanf(fmt_scan_ij, &i, &j);

    # check scanf return value - should be two because we only scan 2 numbers i and j
    cmpq    $2, %rax                    # Expecting 2 inputs
    jne     invalid_input               # If not, jump to invalid_input    

    # valid range for i and j: [1, 254]
    movb  -16(%rbp), %dl     # save the value of i as a third argument (should this be of size 1 byte)
    movb  -15(%rbp), %cl     # save the value of j as a fourth argument

    movq    -24(%rbp), %rdi  # restore pstr1 as a first argument
    movq    -32(%rbp), %rsi  # restore pstr2 as a second argument
    xorb    %al, %al         # clear %al before function call (customary)
    call    pstrijcpy        # pstrijcpy(&pstr1, &pstr2, i, j);

    # print the length and string of the Pstrings
    movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
    movzb   (%rax), %rsi                # load the length of the returned Pstring from pstrijcpy as a second argument
    leaq    1(%rax), %rdx               # copy the address of the string that is stored in the Pstring returned from pstrijcpy
    xorb    %al, %al                    # clear %al before function call (customary)
    call    printf                      # printf(choice_33_34_37_txt, pstrijcpy(&pstr1, &pstr2, i, j)->len, pstrijcpy(&pstr1, &pstr2, i, j)->str);

    movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
    movq    -32(%rbp), %r10             # restore pstr2 to temporary caller saved register r10
    movzb   (%r10), %rsi                # load len of pstr2 as a second argument
    leaq    1(%r10), %rdx               # load str of pstr2 as a third argument
    xorb    %al, %al                    # clear %al before function call (customary)
    call    printf                      # printf(choice_33_34_37_txt, &pstr2->len, &pstr2->str);
    jmp     end_run_func                # end function

    choice_37: # will call pstrcat with both Pstrings
        movq    %rdx, -16(%rbp)        # save pointer to pstr2
        movq    %rsi, %rdi             # set pstr1 as a first argument
        movq    %rdx, %rsi             # set pstr2 as a second argument
        xorb    %al, %al               # clear %al before function call (customary)
        call    pstrcat                # pstrcat(&pstr1, &pstr2);

        movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
        movzbq  (%rax), %r10                # move len of returned value from pstrcat returned value to temporary caller saved register r10
        movzbq  %r10b, %rsi                 # set the len of the returned value from pstrcat as a second argument
        leaq    1(%rax), %rdx               # set the str of the returend value from pstrcat as a third argument
        xorb    %al, %al                    # clear %al before function call (customary)
        call    printf                      # printf(choice_33_34_37, pstrcat(&pstr1, &pstr2)->len, pstrcat(&pstr1, &pstr2)->str);

        movq    $choise_33_34_37_txt, %rdi  # load the text to first argument
        movq    -16(%rbp), %r10             # move len of pstr2 to temporary caller saved register r10
        movzbq  (%r10), %rsi                # load len of pstr2 as a second argument
        leaq    1(%r10), %rdx               # load str of pstr2 as a third argument
        xorb    %al, %al                    # clear %al before function call (customary)
        call    printf                      # printf(choice_33_34_37, &pstr2->len, &pstr2>str);
        jmp     end_run_func                # end function

    invalid_option:
        movq    $invalid_option_txt, %rdi   # load the invalid option message to first argument
        xor     %al, %al                    # clear %al before function call (customary)
        call    printf                      # printf(invalid_option_txt);
        jmp     end_run_func                # end function

    invalid_input:
        movq    $invalid_inpt_txt, %rdi     # load the invalid input message to first argument
        xor     %al, %al                    # clear %al before function call (customary)
        call    printf                      # printf(invalid_input_txt);

    end_run_func:
        xorq    %rax, %rax                  # set return value to 0 (even though this is void but whatever)
        movq    %rbp, %rsp                  # restore the stack pointer
        popq    %rbp                        # restore the old frame pointer
        ret
