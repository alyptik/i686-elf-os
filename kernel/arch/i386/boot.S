#
# _start.s - x86 assembly code that _starts our kernel and sets up environment
#
# Copyright 2017 Joey Pabalinas <alyptik@protonmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Declare constants for the multiboot header.
.set ALIGN, 1 << 0             # align loaded modules on page boundaries
.set MEMINFO, 1 << 1             # provide memory map
.set FLAGS, ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC, 0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a header as in the Multiboot Standard.
.section .multiboot
	.align 4
	.long MAGIC
	.long FLAGS
	.long CHECKSUM

# Reserve a stack for the initial thread.
.section .bss
	.align 16
	stack_bottom:
		.skip 16384 # 16 KiB
	stack_top:

# The kernel entry point.
.section .text
	.global _start
	.type _start, @function
	_start:
		movl $stack_top, %esp

		# Call the global constructors.
		call _init

		# enable the fast A20 gate
		inb $0x92, %al
		# skip A20 init if already enabled
		testb $2, %al
		jnz setup_gdt
		orb $2, %al
		andb $0xfe, %al
		outb %al, $0x92

	setup_gdt:
		cli
		# don't init gdt if already in protected mode
		mov %cr0, %eax
		testb $1, %al
		jnz prot_main

		# generate GDT
		call init_gdt
		# load GDT register with start address of Global Descriptor Table
		lgdt gdtr
		mov %cr0, %eax
		# set PE (Protection Enable) bit in CR0 (Control Register 0)
		orb $1, %al
		mov %eax, %cr0
		# Perform far jump to selector 08h (offset into GDT, pointing at a 32bit PM code segment descriptor)
		# to load CS with proper PM32 descriptor)
		# jmp pmain + 0x08
		jmp prot_main

	prot_main:
		# load DS, ES, FS, GS, SS, ESP.
		# Transfer control to the main kernel.
		call kernel_main

		# Hang if kernel_main unexpectedly returns.
		cli
	1:
		hlt
		jmp 1b

.size _start, . - _start
