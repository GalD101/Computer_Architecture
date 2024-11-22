.extern printf
.extern scanf
.extern srand
.extern  rand
#BUG!!!!! WHEN STARTING A NEW ROUND (NORMAL MODE) USER GETS INFINITE TRIES (ONLY IF HE MADE THREE OR MORE MISTAKES IN THE ROUND BEFORE)!!
#BUG!!!!! WHEN USER STARTS ANOTHER ROUND IN EASY MODE HE ONLY GETS <5 TRIES! (COUNTER IS NOT BEING RESET) HAPPENS ONLY ON SECOND ROUND
#BUG!!!!! USER DOES NOT GET INCORRECT AND GAME OVER MESSAGE WHEN HE LOSES

# TODO: save local variables in stack instead of .data
# .data is for initialized global static
# .rodata is for read only data and is for global static initialized constants
# .bss is for block starting symbol and is for non initialized global static variables


.section		.rodata

M:          .byte 0x05 # M is a the number of tries per round
N:          .quad 0x0A # N is a the initial range for the random number

# prompt messages asking for user input
usr_cnfg_seed_prmpt:	.string "Enter configuration seed: "
usr_easy_mode_prmpt:    .string "Would you like to play in easy mode? (y/n) "
usr_guess_prmpt:	    .string "What is your guess? "

# scanning string formats
fmt_string_digit:       .string "%d"
fmt_string_chr:         .string " %c" # the space is important here to ignore white space before

# this is just for testing
print_digit:            .string "%d\n"
print_chr:              .string "%c\n"

# messages regarding the state of the game
congratulation_msg:		.string "Congratz! You won %u rounds!\n"
incorrect_msg:	        .string "Incorrect. "
over_estimate_msg:      .string "Your guess was above the actual number ...\n"
under_estimate_msg:     .string "Your guess was below the actual number ...\n"
game_over_msg:	        .string "\nGame over, you lost :(. The correct answer was %u\n"
double_or_nothing_msg:  .string "Double or nothing! Would you like to continue to another round? (y/n) "

.section    .text

.global gen_rnd_num
.type gen_rnd_num, @function
gen_rnd_num: # long gen_rnd_num(unsigned long seed, long N)
    # boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
    pushq	%rbp                            # save the old frame pointer
    movq	%rsp,	%rbp	                # create the new frame pointer

    # use stack to create space for local variables
    # I will need one unsigned long which is 8 bytes in 64-bit architecture (parameter seed) and one long which is also 8 bytes in 64-bit architecture (parameter N)
    # so in total I will need 8 + 8 = 16 bytes in the stack (activation frame) for gen_rnd_num
    # but I will immediately call srand with seed so I don't need to save it
    # that means I will only need 8 bytes in the stack
    subq    $010, %rsp            # move rsp to create spcae for local variable N
    pushq   %rsi                  # save N (which is in rsi because it is the second argument). We will need this after the call to srand & rand so save it in the stack (rsi is caller saved so no guarantee callee (here callee is srand(& also rand) and gen_rnd_num is caller) will preserve rsi)

    # Call srand with the seed
    movq    %rdi, %rdi            # set the address of the usr_input_seed as the first (and only) argument for srand (passing by address)
    call    srand
    call    rand                  # the result from rand is now stored at rax (so it is also in eax (same register smaller portion of it)

    # Modulo the result from rand (which is stored in rax) by N and add 1
    popq    %rsi                  # retrieve N
    movq    $0, %rdx              # clear rdx TODO: Check if this is necessary
    movq    %rsi, %rcx
    div     %rcx                  # rax = quotient, rdx = remainder. this is just how div works - not intuitive at all :(
    inc     %rdx                  # add 1 to match the examples in the assignment instructions
    movq    %rdx, %rax            # Store remainder in rax (return value)

    movq    %rbp, %rsp            # close gen_rnd_num activation frame
    popq    %rbp                  # restore activation frame
    ret

.global     main
.type main, @function
main:
# boiler-plate code (copied from the examples in the exercise) to create stack frame (I think)
pushq	%rbp                      # save the old frame pointer
movq	%rsp,	%rbp	          # create the new frame pointer

# create space for local variables
# I will need space for: seed (8 bytes), rnd_num (8 bytes), rounds (8 bytes - or maybe I should use 4 bytes? because the user will spend too much time if he will play that many (2^32) rounds), is_easy_mode (1 byte), cur_N (8 bytes), guess (8 bytes), is_double_or_nothing (1 byte)
# so in total: 8 + 8 + 8(maybe4?) + 1 + 8 + 8 + 1 = 42 = 0b101010 (42 is the meaning of life so I should choose that and not 4 lol)
# apperantly main's stack fram has to be a multiple of 16 anyways, so the closest multiple of 16 is 48.
subq    $48, %rsp                 # create space for local variables

# initialize variable: (this is an optimal ordering (I think) - but it doesn't matter since main's stack fram has to be a multiple of 16 anyways...)
# I could have also used push but then it would be hard to know where certain variables reside (it depends on the sequence we pushed)
movq $0, -48(%rbp)                # Initialize seed to 0
movq $0, -40(%rbp)                # Initialize rnd_num to 0
# Initialize cur_N to N
movq N(%rip), %rax                # Load N (from .rodata) into %rax
movq %rax, -32(%rbp)              # Store cur_N
movq $0, -24(%rbp)                # Initialize guess to 0
movq $1, -16(%rbp)                # Initialize rounds to 1
# Initialize tries_left to M
movb M(%rip), %al                 # Load M (from .rodata) into %al
movb %al, -8(%rbp)                # Store M in tries_left
movb $'n', -7(%rbp)               # Initialize is_easy_mode to 'n'
movb $'n', -6(%rbp)               # Initialize is_double_or_nothing to 'n'


# Print the prompt asking for the seed
movq    $usr_cnfg_seed_prmpt, %rdi
xorb    %al, %al
call    printf

# Scan the seed from the user
movq    $fmt_string_digit, %rdi   # set the format as the first input for scanf (use 8 bytes (rdi and not e.g. edi) for scanf because man page shows signature that shows that first&second arguments are char* and in 64-bit architecture this is 8 bytes)
leaq    -48(%rbp), %rsi           # set the address of the "first" variable in the stack (seed) as the second input for scanf (i.e. scanf("%d", &seed))
call    scanf

# Call gen_rnd_num with seed and N
movq    -48(%rbp), %rdi           # first parameter (seed) goes to rdi
movq    -32(%rbp), %rsi           # second parameter (N) goes to rsi
call    gen_rnd_num
movq    %rax, -40(%rbp)           # save the return value in rnd_num. return is at rax -> rnd_num = get_rnd_num(seed, N);

# Print easy mode prompt
movq    $usr_easy_mode_prmpt, %rdi
xorb    %al, %al                  # We must 0 only the left most byte of rax. see: https://stackoverflow.com/questions/6212665/why-is-eax-zeroed-before-a-call-to-printf
call    printf

# Scan the input from the user
movq    $fmt_string_chr, %rdi           # set the format as the first input for scanf
leaq    -7(%rbp), %rsi                  # I think since we are copying an address, an address in a 64-but architecture is always 8 bit regardless of the value it holds. Thus we use quad (I want to copy the full address and not a part of it, that is why I copy to rsi and not esi). man page of scanf says the 2nd argument is const char* so it is 8 bytes.
xorb    %al, %al
call    scanf

ask_for_guess_loop:

# Print prompt asking for guess
movq    $usr_guess_prmpt, %rdi
xorb    %al, %al
call    printf

# Scan guess from the user
movq    $fmt_string_digit, %rdi
leaq    -24(%rbp), %rsi
xorb    %al, %al
call scanf

# Decrement tries_left counter by 1
movb    -8(%rbp) , %cl            # c in cl is counter (we could have used any other gp register but in the old days rcx was usually used as counter)
decb    %cl
movb    %cl, -8(%rbp)


# The following is analogous to if (!((guess != rnd_num) && (counter != 0))) {goto round_finish;}
# in the C program I wrote before jumping into Assembly

# C: if (guess == rnd_num){goto round_finish;}
movq    -40(%rbp), %rax
cmpq    %rax, -24(%rbp)
je      round_finish

# C: if (counter == 0)
test    %cl, %cl                # this will "perform a 'mental' AND" so we will get ZF=1 iff %cl is 0 
jz      round_finish

# so if we got here, that must mean that ((guess != rnd_num) && (counter != 0))

# Print wrong answer message
movq    $incorrect_msg, %rdi
xorb    %al, %al
call    printf

movzbq   -7(%rbp), %rax           # TODO: Why use the entire rax and not just al? I think there is a reason
cmpb     $'y', %al                # Compare %al (lower 8 bits of rax) with 'y'
je       easy_mode
cmpb     $'n', %al                # Compare %al (lower 8 bits of rax) with 'n'
je       ask_for_guess_loop


# Where should I place this???? In the end of the file??
easy_mode:

# Compare guess and rnd_num
mov     -40(%rbp), %rax           
cmp     -24(%rbp), %rax
jg      below
jmp     above # (can also do jl)
print:
xorb    %al, %al
call    printf
jmp     ask_for_guess_loop
below:
movq    $under_estimate_msg, %rdi
jmp     print
above:
movq    $over_estimate_msg, %rdi
jmp     print

round_finish:
xorq    %rax, %rax
movq    -24(%rbp), %rax
cmpq    -40(%rbp), %rax
je      double_or_nothing
jne     exit    # TEMP NEED TO FIX THIS! (maybe do print winning before exit and print incorrect before exit)


double_or_nothing:
# Print double or nothing prompt
movq    $double_or_nothing_msg, %rdi
xorb    %al, %al
call    printf

# Scan the input from the user
movq    $fmt_string_chr, %rdi            # set the format as the first input for scanf
leaq    -6(%rbp), %rsi
xorb    %al, %al
call    scanf

movq    -6(%rbp), %rax
cmpb    $'y', %al
je      update_new_round

# Print winning message
movq    $congratulation_msg, %rdi
movq    -16(%rbp), %rsi
xorb    %al, %al
call    printf
jmp exit

update_new_round:

# Increment rounds counter
movq    -16(%rbp), %rax
incq    %rax
movq    %rax, -16(%rbp)

# multiply seed by 2 using shifts
movq    -48(%rbp), %rax
shlq    $1, %rax
movq    %rax, -48(%rbp)

# multiply N by 2 using shifts
movq    -32(%rbp), %rax
shlq    $1, %rax
movq    %rax, -32(%rbp) # SEGFAULT HERE

# reset tries left counter
movb    M(%rip), %al
movb    -8(%rbp), %al

# generate new random number
movq    -48(%rbp), %rdi
movq    -32(%rbp), %rsi
call    gen_rnd_num
movq    %rax, -40(%rbp)

# go to loop again to start a new round
jmp ask_for_guess_loop


exit:
# boiler-plate code to exit program
movq    $0, %rax                        # return value is zero (just like in c - we tell the OS that this program finished seccessfully)
movq    %rbp, %rsp                      # restore the old stack pointer - release all used memory.
popq    %rbp                            # restore old frame pointer (the caller function frame)
ret                                     # return to caller function (OS)
