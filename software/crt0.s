.section .init, "ax"			# Put this in the .init section (in an executable allocatable region)
.global _start					# expose _start symbol to linker
_start:							# begin _start symbol definition
	.cfi_startproc
	.cfi_undefined ra 			# don't restore Return Address register
	.option push				# save current ASM settings
	.option norelax				
	la gp, __global_pointer$	# set global pointer
	.option pop					# restore previous ASM settings
	la sp, __stack_top			# set stack pointer to __stack_top
	add s0, sp, zero			# set frame pointer (s0) to sp
	jal zero, main				# unconditional jump to main
	.cfi_endproc
	.end						# end of assembly file
