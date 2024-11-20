.extern	printf
.extern atoi

.section .data
	.align	16
x:	.long	0
y:	.long	0
z:	.long	0

.section .rodata
fmt:	.string	"(%d+%d)*%d = %d\n"
err:   	.string "Error: not enough arguments\n"

.section .text
.globl	main
.type	main, @function
main:
	# Enter
	pushq	%rbp
	movq	%rsp, %rbp

	# main, just like in C, is a function!
	# this means that:
	# rdi = argc
	# rsi = argv

	# Check if argc < 4
	cmpq	$4, %rdi
	jae 	.continue
	movq	$err, %rdi
	xorq    %rax, %rax
	call	printf
	jmp 	.end

.continue:
	# store rsi in r12 to make sure we don't lose it
	movq	%rsi, %r12

	# x = atoi(argv[1])
	movq	0x8(%r12), %rdi # rdi = argv[1]
	xorq	%rax, %rax
	call	atoi
	movq	$x, %rdi
	movq	%rax, (%rdi)

	# y = atoi(argv[2])
	movq	0x10(%r12), %rdi # rdi = argv[2]
	xorq	%rax, %rax
	call	atoi
	movq	$y, %rdi
	movq	%rax, (%rdi)

	# z = atoi(argv[3])
	movq	0x18(%r12), %rdi # rdi = argv[3]
	xorq	%rax, %rax
	call	atoi
	movq	$z, %rdi
	movq	%rax, (%rdi)

	# calling sum(x,y)
	movq	$x, %rdi
	movq	(%rdi), %rdi
	movq	$y, %rsi
	movq	(%rsi), %rsi
	call	sum

	# calling mult((x+y),z)
    movq	$z, %rsi
	movq	(%rsi), %rsi
	movq	%rax, %rdi
	call	mult

	# calling printf(fmt, x, y, z, result)
	movq	$fmt, %rdi
	movq	$x, %rsi
	movq	(%rsi), %rsi
	movq	$y, %rdx
	movq	(%rdx), %rdx
	movq	$z, %rcx
	movq	(%rcx), %rcx
	movq	%rax, %r8
	xorq	%rax, %rax
	call	printf
	
	# Leave
.end:
	movq	%rbp, %rsp
	popq	%rbp
	ret

.type	sum, @function
sum:
	# Enter
	pushq	%rbp
	movq	%rsp, %rbp

	# rax = rdi + rsi
	movq	%rdi, %rax
	addq	%rsi, %rax

	# Leave
	movq	%rbp, %rsp
	popq	%rbp
	ret
	
.type	mult, @function
mult:
	# Enter
	pushq	%rbp
	movq	%rsp, %rbp

	# rax = rdi * rsi
	movq	%rdi, %rax
	imulq	%rsi, %rax

	# Leave
	movq	%rbp, %rsp
	popq	%rbp
	ret
