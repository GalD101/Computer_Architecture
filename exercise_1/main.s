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
    scanf_fmt_yes_or_no:    .string "%c"

    usr_guess_prmpt:	    .string "What is your guess? "
    scanf_fmt_guess:        .string "%d"

    # messages regarding the state of the game
    correct:			.string "Congratz! You won %u rounds!\n"
    incorrect:		    .string "Incorrect. "
    game_over:		    .string "Game over, you lost :(. The correct answer was %u\n"

########################


########################
.section .data

    # create memory for the user input
    usr_input_seed: .int 0x00
    usr_input_guess: .int 8, 0x00
    rnd_num_generated: .long 0x00
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
    # boiler-plate code start
    pushq	%rbp		#save the old frame pointer
	movq	%rsp,	%rbp	#create the new frame pointer
    # boiler-plate code end

        # Print the prompt asking for the seed
    movq    $usr_cnfg_seed_prmpt, %rdi
    movq    $0, %rax
    call    printf

    # Scan the seed from the user
    mov     $scanf_fmt_seed, %rdi           # Ensure this is "%d" for scanf
    lea     usr_input_seed(%rip), %rsi
    call    scanf

    # Call srand with the seed
    movq    usr_input_seed(%rip), %rdi
    movq    $0, %rax
    call    srand

    # Call rand and store its return value
    movq    $0, %rdi                        # Not needed for rand, but safe
    movq    $0, %rax
    call    rand
    movq    %rax, %rdx                      # Store rand result in rdx for division
    
    # Modulo the result by 11
    xorq    %rdx, %rdx                      # Clear rdx before division
    movq    $10, %rcx                       # Set divisor to 10
    div     %rcx                            # rax = quotient, rdx = remainder
    inc     %rdx
    movq    %rdx, rnd_num_generated(%rip)   # Store remainder in rnd_num_generated

    # Print the random value (mod result)
    movq    $scanf_fmt_seed, %rdi               # printf format string like "%d\n"
    movq    rnd_num_generated(%rip), %rsi   # Load the result to be printed
    movq    $0, %rax                        # Clear rax for variadic function
    call    printf


    
	
	movq	$0, %rax	#return value is zero (just like in c - we tell the OS that this program finished seccessfully)
	movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
	popq	%rbp		#restore old frame pointer (the caller function frame)
	ret			#return to caller function (OS)
