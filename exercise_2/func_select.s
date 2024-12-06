# Implement void run_func(int choice, Pstring *pstr1, Pstring *pstr2) here

.section		      .rodata
choise_31_txt:        .string "first pstring length: %d, second pstring length: %d\n"
choise_33_34_37_txt:  .string "length: %d, string: %s\n"
invalid_option_txt:   .string "invalid option!\n"
invalid_inpt_txt:     .string "invalid input!\n"

fmt_scan_ij:          .string " %hhu %hhu"

.align 8 # Align address to multiple of 8
switch_choice_jmp_tbl:
.quad   choice_31               # 31 - valid option
.quad   invalid_option          # 32 - invalid option
.quad   choice_33               # 33 - valid option
.quad   choice_34               # 34 - valid option
.quad   invalid_option          # 35 - invalid option
.quad   invalid_option          # 36 - invalid option
.quad   choice_37               # 37 - valid option


.section    .text

.globl run_func
.type run_func, @function
run_func:
    # %rdi = choice (int so use %edi), %rsi = &pstr1, %rdx = &pstr2

    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                    # save the old frame pointer
    movq	%rsp,	%rbp	        # create the new frame pointer

    subq    $16, %rsp

    leal    -31(%edi), %eax
    cmpl    $6, %eax
    ja      invalid_option
    jmp     *switch_choice_jmp_tbl(,%eax,8)
    
    choice_31:
    movq   %rsi, -16(%rbp)        # save pointer to pstr1
    movq   %rdx, -8(%rbp)         # save pointer to pstr2

    movq    %rsi, %rdi  # set pstr1 as the first argument
    xorq    %rax, %rax  # clear rax before function call (customary)
    call    pstrlen     # pstrlen(&pstr1);

    movq    %rax, -16(%rbp)   # save the returned length from pstrlen in the stack (instead of pointer to pstr1 because we are done with it)
    movq    -8(%rbp), %rdi
    xorq    %rax, %rax
    call    pstrlen
    movzb   %al, %rdx
    movq    $choise_31_txt, %rdi
    movq    -16(%rbp), %rsi
    xorb    %al, %al
    call    printf
    jmp     end_run_func

    choice_33:
    movq   %rsi, -16(%rbp)        # save pointer to pstr1
    movq   %rdx, -8(%rbp)         # save pointer to pstr2

    movq    %rsi, %rdi  # set pstr1 as the first argument
    xorq    %rax, %rax  # clear rax before function call (customary)
    call    swapCase    # swapCase(&pstr1);
    movq    $choise_33_34_37_txt, %rdi
    movzb   (%rax), %rsi
    leaq    1(%rax), %rdx
    xorb    %al, %al
    call    printf

    movq    -8(%rbp), %rdi
    xorq    %rax, %rax
    call    swapCase
    movq    $choise_33_34_37_txt, %rdi
    movzb   (%rax), %rsi
    leaq    1(%rax), %rdx
    xorb    %al, %al
    call    printf
    jmp     end_run_func

    choice_34:
    subq    $16, %rsp                 # allocate 16 more bytes in the stack
    movb    $0, -16(%rbp)             # Initialize i to 0
    movb    $0, -15(%rbp)             # Initialize j to 0
    movq    %rdx, -32(%rbp)
    movq    %rsi, -24(%rbp)
    # Scan i & j from the user
    movq    $fmt_scan_ij, %rdi         # set the format as the first input for scanf (use 8 bytes (rdi and not e.g. edi) for scanf because man page shows signature that shows that first&second arguments are char* and in 64-bit architecture this is 8 bytes)
    leaq    -16(%rbp), %rsi
    leaq    -15(%rbp), %rdx
    xorb    %al, %al
    call    scanf                      # TODO: Perhaps I can use the return value of scanf to make sure the input was valid
    # check scanf return value - should be two because we only scan 2 numbers i and j
    cmpq    $2, %rax           # Expecting 2 inputs
    jne     invalid_input      # If not, jump to error handling

    # check that i <= j <==> !(i > j)
    movb    -15(%rbp), %cl
    movb    -16(%rbp), %dl
    cmpb    %cl, %dl
    ja      invalid_input

    # save len in caller saved registers:
    movq    -32(%rbp), %rax
    movzbw  (%rax), %r10w           # load length of dst into the lower part of %r10
    movq    -24(%rbp), %rax
    movzbw  (%rax), %r11w           # load length of src into the lower part of %r11

    # calculate min(len of src, len of dst)
    # cool trick to implement min(or max) function: https://stackoverflow.com/questions/42760054/assembly-find-max-of-two-value
    # cmovb only works for 16 bit registers and higher :( that's why I need to use r10e and r11w instead of the smaller r10b and r11b
    cmpb    %r10b, %r11b
    cmovb   %r11w, %r10w             # suppose dst(src) is shorter, if it is not shorter then src(dst) must be shorter.
    cmpb    %r10b, %cl               # check that j < min(len of src, len of dst) <==> !(j >= min(len of src, len of dst))
    jae     invalid_input

    movzbl  -16(%rbp), %edx
    movzbl  -15(%rbp), %ecx

    movq    -32(%rbp), %rSi
    movq    -24(%rbp), %rDi
    xorb    %al, %al
    call    pstrijcpy

    # print
    movq    $choise_33_34_37_txt, %rdi
    movzb   (%rax), %rsi
    leaq    1(%rax), %rdx
    xorb    %al, %al
    call    printf

    movq    $choise_33_34_37_txt, %rdi
    movq    -32(%rbp), %r10
    movzb   (%r10), %rsi
    leaq    1(%r10), %rdx
    xorb    %al, %al
    call    printf
    jmp     end_run_func

    choice_37:
    movq    %rsi, -16(%rbp)        # save pointer to pstr1
    movq    %rdx, -8(%rbp)         # save pointer to pstr2
    movq    %rsi, %rdi
    movq    %rdx, %rsi
    xorb    %al, %al
    call pstrcat

    movq    $choise_33_34_37_txt, %rdi
    movq    (%rax), %r10
    movzbw  (%r10), %r10w
    movq    (%r10), %rsi
    leaq    1(%r10), %rdx
    xorb    %al, %al
    call    printf


    movq    -8(%rbp), %r10
    movzbw  (%r10), %r10w
    movq    $choise_33_34_37_txt, %rdi
    movq    (%r10), %rsi
    leaq    1(%r10), %rdx
    xorb    %al, %al
    call    printf
    jmp     end_run_func

    invalid_option:
        movq    $invalid_option_txt, %rdi
        xor     %rax, %rax
        call    printf
        jmp     end_run_func

    invalid_input:
        movq    $invalid_inpt_txt, %rdi
        xor     %rax, %rax
        call    printf

    end_run_func:
        movq    %rbp, %rsp
        popq    %rbp
        ret
