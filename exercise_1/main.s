.extern printf
.extern scanf
.extern srand
.extern  rand

########################

.section		.rodata

# Initial values for N and M
M:          .quad 0x05

# yes and no characters to determine flow
yes_chr:    .byte 'y'
no_chr:     .byte 'n'

# prompt messages asking for user input
usr_cnfg_seed_prmpt:	.string "Enter configuration seed: "
scanf_fmt_seed:         .string "%d"

usr_easy_mode_prmpt:    .string "Would you like to play in easy mode? (y/n) "
scanf_fmt_chr:          .string " %c" # the space is important here to ignore white space before
testingggg:    .string "%ld\n"
print_digit:    .string "%d\n"
print_chr:      .string "%c\n"

usr_guess_prmpt:	    .string "What is your guess? "
scanf_fmt_guess:        .string "%d"

# messages regarding the state of the game
correct:			.string "Congratz! You won %u rounds!\n"
incorrect:		    .string "Incorrect. "
over_estimate:      .string "Your guess was above the actual number ...\n"
under_estimate:     .string "Your guess was below the actual number ...\n"
game_over:		    .string "\nGame over, you lost :(. The correct answer was %u\n"
double_or_nothing_msg:  .string "Double or nothing! Would you like to continue to another round? (y/n) "

########################
.section .data

N:          .quad 0x0A # Will grow exponentially
tries_left: .byte 0x05
rounds:     .quad 0x01 # quad just to be safe
# create memory for the user input
usr_input_seed:         .long 0x00 # Let the seed be a long (matches int according to presentation 4 slide 34) because srand signature is srand(unsigned int seed);
usr_input_yes_or_no:    .byte 0    # This can only take 'y' or 'n' so it should only be 1 byte
usr_input_guess:        .quad 0x00 # The guess could get very big if we continue to more round (in fact the game becomes harder exponentially)
rnd_num_generated:      .quad 0x00 # This can get very big when we go to hugher round
is_double_or_nothing:   .byte 0    # This can only take 'y' or 'n' so it should only be 1 byte
########################

.section    .text



.global gen_rnd_num
.type gen_rnd_num, @function
gen_rnd_num:
    # boiler-plate code (copied from the examples in the exercise)
    pushq	%rbp                            # save the old frame pointer
    movq	%rsp,	%rbp	                # create the new frame pointer

    pushq   %rsi                            # save N (which is in rsi). We will need this after the call to srand & rand so save it in the stack
    # Call srand with the seed
    movl    %edi, %edi                      # set the address of the usr_input_seed as the first (and only) argument for srand (passing by address)
    call    srand

    # Call rand
    call    rand                            # the result from rand is now stored at rax (so it is also in eax (same register smaller portion of it)

    # Modulo the result from rand (which is stored in rax) by N and add 1
    popq    %rsi                            # retrieve N
    movq    $0, %rdx                        # clear rdx TODO: Check if this is necessary
    movq    %rsi, %rcx
    div     %rcx                            # rax = quotient, rdx = remainder. this is just how div works - not intuitive at all :(
    inc     %rdx                            # add 1 to match the examples in the assignment instructions
    movq    %rdx, rnd_num_generated(%rip)   # Store remainder in rnd_num_generated
    movq    rnd_num_generated(%rip), %rax

    popq    %rbp
    ret

.global     main
.type main, @function
main:
# boiler-plate code (copied from the examples in the exercise)
pushq	%rbp                            # save the old frame pointer
movq	%rsp,	%rbp	                # create the new frame pointer


# Print the prompt asking for the seed
movq    $usr_cnfg_seed_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan the seed from the user
movq    $scanf_fmt_seed, %rdi           # set the format as the first input for scanf
leaq    usr_input_seed(%rip), %rsi      # set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
call    scanf


movl    usr_input_seed(%rip), %edi
movq    N(%rip), %rsi
call    gen_rnd_num
movq    %rax, rnd_num_generated(%rip)


# Print easy mode prompt
movq    $usr_easy_mode_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan the input from the user
movq    $scanf_fmt_chr,         %rdi      # set the format as the first input for scanf
leaq    usr_input_yes_or_no(%rip), %rsi # TODO: check if leaw is good or just lea. set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
movq    $0, %rax
call    scanf

movb    M(%rip), %cl                         # ECX is for counter (according to lecture 4 slide 9) so I will use only the last 8 bits of it (internet says it is cl) The counter will be initialized to M. zbl will make the rest of the register filled with 0's
movb    %cl, tries_left(%rip)
ask_for_guess_loop:

# Print prompt asking for guess
movq    $usr_guess_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan guess from the user
movq    $scanf_fmt_guess, %rdi
leaq    usr_input_guess(%rip), %rsi
movq    $0, %rax
call scanf


# TESTING should print 5 
movq    $print_digit, %rdi       # Load format string "%ld\n"
mov     tries_left(%rip), %sil   # Load the random number
movq    $0, %rax                 # Clear %rax for variadic functions
call    printf                   # Print the number
##################

movb    tries_left(%rip), %cl
decb    %cl
movb    %cl, tries_left(%rip)


# The following is analogous to if (!((guess != rnd_num) && (counter != 0))) {goto round_finish;}
# in the C program I wrote before jumping into Assembly

# C: if (guess == rnd_num){goto round_finish;}
movq    rnd_num_generated(%rip), %rax
cmpq    %rax, usr_input_guess(%rip)
je      round_finish

# C: if (counter == 0)
test    %cl, %cl                # this will "perform a 'mental' AND" so we will get ZF=1 iff %cl is 0 
jz      round_finish

# so if we got here, that must mean that ((guess != rnd_num) && (counter != 0))

# Print wrong answer message
movq    $incorrect, %rdi
movq    $0, %rax
call    printf


# THIS IS JUST FOR DEBUGGING PURPOSES!
movq    $print_chr, %rdi
movq    usr_input_yes_or_no(%rip), %rsi
movq    $0, %rax
call    printf



movzbq   usr_input_yes_or_no(%rip), %rax # Load the value into %rax
cmpb     $'y', %al                      # Compare %al (lower 8 bits of rax) with 'y'
je       easy_mode
cmpb     $'n', %al                      # Compare %al (lower 8 bits of rax) with 'n'
je       ask_for_guess_loop


# Where should I place this???? In the end of the file??
easy_mode:
mov     rnd_num_generated(%rip), %rax
cmp     usr_input_guess(%rip), %rax
jg      below
jmp     above
print:
movq    $0, %rax
call    printf
jmp     ask_for_guess_loop
below:
movq    $under_estimate, %rdi
jmp     print
above:
movq    $over_estimate, %rdi
jmp     print



// je easy_mode
// cmp $'n', %rax
// je not_easy_mode













// # Testing - Delete this when finished
// # Prepare to print rnd_num_generated
// movq    $testingggg, %rdi        # Load format string "%ld\n"
// movq    rnd_num_generated(%rip), %rsi  # Load the random number
// movq    $0, %rax                 # Clear %rax for variadic functions
// call    printf                   # Print the number
// ##################






round_finish:
xor     %rax, %rax
movq    usr_input_guess(%rip), %rax
cmpq    rnd_num_generated(%rip), %rax
je      double_or_nothing
jne     exit    # TEMP NEED TO FIX THIS! (maybe do print winning before exit and print incorrect before exit)


double_or_nothing:
# Print double or nothing prompt
movq    $double_or_nothing_msg, %rdi
movq    $0, %rax
call    printf

# Scan the input from the user
movq    $scanf_fmt_chr, %rdi            # set the format as the first input for scanf
leaq    is_double_or_nothing(%rip), %rsi
movq    $0, %rax
call    scanf

# THIS IS JUST FOR DEBUGGING PURPOSES!
movq    is_double_or_nothing(%rip), %rax
cmpb    $'y', %al
je      update_new_round

# Print winning message
movq    $correct, %rdi
leaq    rounds(%rip), %rsi
movq    $0, %rax
call    printf


exit:
# boiler-plate code to exit program
movq    $0, %rax                        # return value is zero (just like in c - we tell the OS that this program finished seccessfully)
movq    %rbp, %rsp                      # restore the old stack pointer - release all used memory.
popq    %rbp                            # restore old frame pointer (the caller function frame)
ret                                     # return to caller function (OS)
