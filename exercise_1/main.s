.extern printf
.extern scanf
.extern srand
.extern  rand

########################

.section		.rodata

# yes and no characters to determine flow
yes_chr:    .byte 'y'
no_chr:     .byte 'n'

# prompt messages asking for user input
usr_cnfg_seed_prmpt:	.string "Enter configuration seed: "
scanf_fmt_seed:         .string "%d"

usr_easy_mode_prmpt:    .string "Would you like to play in easy mode? (y/n) "
scanf_fmt_yes_or_no:    .string " %c" # the space is important here to ignore white space before

usr_guess_prmpt:	    .string "What is your guess? "
scanf_fmt_guess:        .string "%d"

# messages regarding the state of the game
correct:			.string "Congratz! You won %u rounds!\n"
incorrect:		    .string "Incorrect. "
game_over:		    .string "Game over, you lost :(. The correct answer was %u\n"

########################
.section .data

# create memory for the user input
usr_input_seed:         .int 0x00
usr_input_yes_or_no:    .byte 0x00
usr_input_guess:        .int 8, 0x00
rnd_num_generated:      .long 0x00
########################





# TODO:
#       create labels so it will be easy to follow the program and how it runs
#       figure out how to read user input
#       before coding, make sure you understand the flow and what should happen
#       don't use main as a function. Refer to what they learned in class
#       create labels for each step of the program and set flag is rodata to determine what mode to run (easy mode, double or nothing, or the noraml one)



.section    .text
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
mov     $scanf_fmt_seed, %rdi           # set the format as the first input for scanf
lea     usr_input_seed(%rip), %rsi      # set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
call    scanf

# Call srand with the seed
movq    usr_input_seed(%rip), %rdi      # set the address of the usr_input_seed as the first (and only) argument for srand (passing by address)
movq    $0, %rax                        # clear the rax register (it is customary to do this before every function call)
call    srand

# Call rand
movq    $0, %rdi                        # zero the rdi register (WHY?????)
movq    $0, %rax                        # clear the rax register (it is customary to do this before every function call)
call    rand                            # the result from rand is now stored at rax (so it is also in eax (same register smaller portion of it)

# Modulo the result from rand (which is stored in rax) by 10 and add 1
movq    $0, %rdx                        # clear rdx
movq    $10, %rcx
div     %rcx                            # rax = quotient, rdx = remainder. this is just how div works - not intuitive at all :(
inc     %rdx                            # add 1 to match the examples in the assignment instructions
movq    %rdx, rnd_num_generated(%rip)   # Store remainder in rnd_num_generated

# Print easy mode prompt
movq    $usr_easy_mode_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan the input from the user
mov     $scanf_fmt_yes_or_no, %rdi      # set the format as the first input for scanf
lea     usr_input_yes_or_no(%rip), %rsi # set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
movq    $0, %rax
call    scanf

# Print prompt asking for guess
movq    $usr_guess_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan guess from the user
mov     $scanf_fmt_guess, %rdi
lea     usr_input_guess(%rip), %rsi
movq    $0, %rax
call scanf

# determine the flow based on the user's input
# TODO

movq    usr_input_yes_or_no(%rip), %rax # copy the value of the user's guess to a temporary register in order to compare
cmpq    $yes_chr, %rax                  # check if user said yes (y)
je      easy_mode
cmpq    $no_chr, %rax                   # check if user said no (n)
je      not_easy_mode


not_easy_mode:
# boiler-plate code to exit program
movq    $0, %rax                        # return value is zero (just like in c - we tell the OS that this program finished seccessfully)
movq    %rbp, %rsp                      # restore the old stack pointer - release all used memory.
popq    %rbp                            # restore old frame pointer (the caller function frame)
ret                                     # return to caller function (OS)












easy_mode:

# Print the random value (mod result) (testing)
movq    $scanf_fmt_seed, %rdi           # printf format string like "%d\n"
movq    rnd_num_generated(%rip), %rsi   # Load the result to be printed
movq    $0, %rax                        # Clear rax for variadic function
call    printf












# Print the random value (mod result) (testing)
// movq    $scanf_fmt_seed, %rdi           # printf format string like "%d\n"
// movq    rnd_num_generated(%rip), %rsi   # Load the result to be printed
// movq    $0, %rax                        # Clear rax for variadic function
// call    printf

