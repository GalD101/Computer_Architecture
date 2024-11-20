	.extern	printf
	
	.section	.rodata
fmt_str:
	.string	"%c %c %c %c %c %c %c\n"
	
	.section	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp

	# printf("%c %c %c %c %c %c %c\n", 'a', 'b', 'c', 'd', 'e', 'f', 'g')
	pushq	$103
	pushq	$102
	movq	$101, %r9
	movq	$100, %r8
	movq	$99, %rcx
	movq	$98, %rdx
	movq	$97, %rsi
	movq 	$fmt_str, %rdi
	xorq	%rax, %rax
	call	printf

	movq %rbp, %rsp
	popq %rbp
	ret
