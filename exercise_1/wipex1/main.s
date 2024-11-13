.extern printf
.extern scanf


.section		.rodata
N:			.int 0xA
M:			.int 0x05
usr_cnfg_seed_prmpt:	.string "Enter configuration seed: "
usr_guess_prmpt:	.string "What is your guess? "
correct:			.string "Congratz! You won!\n"
incorrect:		.string "Incorrect.\n"
game_over:		.string "Game over, you lost :(. The correct answer was %u\n"
fmt:			.asciz "%d\n"

scanf_fmt_seed:		.asciz "%d"


.section .data
usr_input_seed: .int 8, 0x00
usr_input_guess: .int 8, 0x00


.section	.text
.globl main
.type main, @function
main:
	# boilerplate code to setup stack
	# ------------
	pushq %rbp
	movq %rsp, %rbp
	# ------------

	# print the prompt for the seed configuration
	movq $usr_cnfg_seed_prmpt, %rdi
	xor %rax, %rax
	call printf

	# scan the user input for the seed
	movq $scanf_fmt_seed, %rdi
	movq $usr_input_seed, %rsi
	xorq %rax, %rax
	call scanf

	movq $usr_input_seed, %rdi
        xor %rax, %rax
        call srand

	xor %rax, %rax
	call rand

	movq $fmt, %rdi
	movq %rax, %rsi
	xor %rax, %rax
	call printf


	xorq %rax, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
