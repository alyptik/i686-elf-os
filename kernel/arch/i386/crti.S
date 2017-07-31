.section .init
	.global _init
	.type _init, @function
	_init:
		push %ebp
		movl %esp, %ebp

		# enable the fast A20 gate
		inb $0x92, %al
		testb $2, %al
		jnz after
		orb $2, %al
		andb $0xfe, %al
		outb %al, $0x92

	after:
		/* gcc will nicely put the contents of crtbegin.o's .init section here. */

		cli          # disable interrupts
		lgdt (gdtr) # load GDT register with start address of Global Descriptor Table
		mov %cr0, %eax
		or $1, %al     # set PE (Protection Enable) bit in CR0 (Control Register 0)
		mov %eax, %cr0
		#
		# # Perform far jump to selector 08h (offset into GDT, pointing at a 32bit PM code segment descriptor)
		# # to load CS with proper PM32 descriptor)
		#
		jmp PModeMain + 0x08
		#
		# # [...]
		#
		PModeMain:
		# # load DS, ES, FS, GS, SS, ESP.

.section .fini
	.global _fini
	.type _fini, @function
	_fini:
		push %ebp
		movl %esp, %ebp
		/* gcc will nicely put the contents of crtbegin.o's .fini section here. */
