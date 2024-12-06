# Implement void run_func(int choice, Pstring *pstr1, Pstring *pstr2) here

.section		      .rodata
choise_31_txt:        .string "first pstring length: %d, second pstring length: %d\n"
choise_33_34_37_txt:  .string "length: %d, string: %s\n"
invalid_option_txt:   .string "invalid option!\n"

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
    jmp     end_run_runc

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
    jmp     end_run_runc

    choice_34:
    and     %rax, %rax

    choice_37:
    and     %rax, %rax

    invalid_option:
    and     %rax, %rax

    end_run_runc:
        movq    %rbp, %rsp              # close pstrlen activation frame
        popq    %rbp                    # restore activation frame
        ret
