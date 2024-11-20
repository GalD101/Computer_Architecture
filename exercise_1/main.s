.extern printf
.extern scanf
.extern srand
.extern  rand

########################

.section		.rodata

# Initial values for N and M
N:          .quad 0x0A # Will grow exponentially
M:          .quad 0x05

# yes and no characters to determine flow
yes_chr:    .byte 'y'
no_chr:     .byte 'n'

# prompt messages asking for user input
usr_cnfg_seed_prmpt:	.string "Enter configuration seed: "
scanf_fmt_seed:         .string "%d"

usr_easy_mode_prmpt:    .string "Would you like to play in easy mode? (y/n) "
scanf_fmt_yes_or_no:    .string " %c" # the space is important here to ignore white space before
testingggg:    .string "%c"

usr_guess_prmpt:	    .string "What is your guess? "
scanf_fmt_guess:        .string "%d"

# messages regarding the state of the game
correct:			.string "Congratz! You won %u rounds!\n"
incorrect:		    .string "Incorrect. "
game_over:		    .string "\nGame over, you lost :(. The correct answer was %u\n"
double_or_nothing:  .string "Double or nothing! Would you like to continue to another round? (y/n) "

########################
.section .data

# create memory for the user input
usr_input_seed:         .quad 0x00 # Let the seed be a quad because it may be very big
usr_input_yes_or_no:    .byte 0 # This can only take 'y' or 'n' so it should only be 1 byte
usr_input_guess:        .quad 0x00 # The guess could get very big if we continue to more round (in fact the game becomes harder exponentially)
rnd_num_generated:      .quad 0x00 # This can get very big when we go to hugher round
########################





# TODO:
#       create labels so it will be easy to follow the program and how it runs
#       figure out how to read user input
#       before coding, make sure you understand the flow and what should happen
#       don't use main as a function. Refer to what they learned in class
#       create labels for each step of the program and set flag is rodata to determine what mode to run (easy mode, double or nothing, or the noraml one)
# Change suffix from q to something that is more memory efficient


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
movq    $scanf_fmt_seed, %rdi           # set the format as the first input for scanf
leaq    usr_input_seed(%rip), %rsi      # set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
call    scanf


# call gen_rnd_num(seed, N, rounds)
#################################################################################################################################################
# Call srand with the seed
movq    usr_input_seed(%rip), %rdi      # set the address of the usr_input_seed as the first (and only) argument for srand (passing by address)
movq    $0, %rax                        # clear the rax register (it is customary to do this before every function call)
call    srand

# Call rand
movq    $0, %rdi                        # zero the rdi register (WHY?????)
movq    $0, %rax                        # clear the rax register (it is customary to do this before every function call)
call    rand                            # the result from rand is now stored at rax (so it is also in eax (same register smaller portion of it)

# Modulo the result from rand (which is stored in rax) by N and add 1
movq    $0, %rdx                        # clear rdx
movq    N(%rip), %rcx
div     %rcx                            # rax = quotient, rdx = remainder. this is just how div works - not intuitive at all :(
inc     %rdx                            # add 1 to match the examples in the assignment instructions
movq    %rdx, rnd_num_generated(%rip)   # Store remainder in rnd_num_generated
#################################################################################################################################################


# Print easy mode prompt
movq    $usr_easy_mode_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan the input from the user
movq    $scanf_fmt_yes_or_no, %rdi      # set the format as the first input for scanf
leaq    usr_input_yes_or_no(%rip), %rsi # TODO: check if leaw is good or just lea. set the address of usr_input_seed as the second input for scanf (i.e. scanf("%d", &usr_input_seed))
movq    $0, %rax
call    scanf


ask_for_guess:
# Print prompt asking for guess
movq    $usr_guess_prmpt, %rdi
movq    $0, %rax
call    printf

# Scan guess from the user
movq    $scanf_fmt_guess, %rdi
leaq    usr_input_guess(%rip), %rsi
movq    $0, %rax
call scanf

# TODO determine the flow based on the user's input


# TODO: THIS IS INEFFICIENT SINCE WE ARE CHECKING IT EVERY TIME WE JMP TO ask_for_guess
# Check if easy mode or not
mov usr_input_yes_or_no(%rip), %rax
cmp $'y', %rax
je easy_mode
cmp $'n', %rax
je not_easy_mode

not_easy_mode:  
# TODO This is copy paste (here ans in easy_mode), maybe find a way to reduce code completion Compare guess with actual random number
movq    rnd_num_generated(%rip), %rax
movq    usr_input_guess(%rip), %rbx
cmp     %rax, %rbx
je double_or_nothing

# Print wrong answer message and go back to asking for guess
movq    $incorrect, %rdi
movq    $0, %rax
call    printf
jmp     ask_for_guess




easy_mode:
# Compare guess with actual random number
movq    rnd_num_generated(%rip), %rax
movq    usr_input_guess(%rip), %rbx
cmp     %rax, %rbx


double_or_nothing:



# boiler-plate code to exit program
movq    $0, %rax                        # return value is zero (just like in c - we tell the OS that this program finished seccessfully)
movq    %rbp, %rsp                      # restore the old stack pointer - release all used memory.
popq    %rbp                            # restore old frame pointer (the caller function frame)
ret                                     # return to caller function (OS)
