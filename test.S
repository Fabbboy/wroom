	.file	"test.c"
	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	otherFunc                       # -- Begin function otherFunc
	.p2align	4
	.type	otherFunc,@function
otherFunc:                              # @otherFunc
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	otherFunc, .Lfunc_end1-otherFunc
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 20.0.0 (++20250128081934+f4de28a63c81-1~exp1~20250128082046.692)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
