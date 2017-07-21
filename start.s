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

# We declare the 'kernel_main' label as being external to this file.
# That's because it's the name of the main C function in 'kernel.c'.
.extern kernel_main

# We declare the '_start' label as global (accessible from outside this file),
# since the linker will need to know where it is.
# In a bit, we'll actually take a look at the code that defines this label.
# The linker script specifies _start as the entry point to the kernel and the
# bootloader will jump to this position once the kernel has been loaded. It
# doesn't make sense to return from this function as the bootloader is gone.
.global _start
.type _start, @function

# Our bootloader, GRUB, needs to know some basic information about our kernel
# before it can boot it.
# We give GRUB this information using a standard known as 'Multiboot'.
# To define a valid 'Multiboot header' that will be recognised by GRUB, we need
# to hard code some
# constants into the executable. The following code calculates those constants.
# This is a 'magic' constant that GRUB will
# use to detect our kernel's location.
.set MB_MAGIC, 0x1BADB002
# This tells GRUB to 1: load modules on page
# boundaries and 2: provide a memory map (this is useful later in development)
.set MB_FLAGS, (1 << 0) | (1 << 1)
# Finally, we calculate a checksum that includes all the previous values
.set MB_CHECKSUM, (0 - (MB_MAGIC + MB_FLAGS))

# We now _start the section of the executable that will contain our Multiboot header
.section .multiboot
	# Make sure the following data is aligned on a multiple of 4 bytes
	# Use the previously calculated constants in executable code
	.align 4
	.long MB_MAGIC
	.long MB_FLAGS
	# Use the checksum we calculated earlier
	.long MB_CHECKSUM

# This section contains data initialised to zeroes when the kernel is loaded
.section .bss
	# Our C code will need a stack to run. Here, we allocate 1024 bytes
	# (or 1 Kilobyte) for our stack.
	# We can expand this later if we want a larger stack. For now, it will
	# be perfectly adequate.
	.align 16
	stack_bottom:
		.skip 16384 # 16 KiB
	stack_top:

# This section contains our actual assembly code to be run when our kernel loads
.section .text
	# Here is the '_start' label we mentioned before. This is the first code
	# that gets run in our kernel.
	_start:
		# First thing's first: we want to set up an environment that's
		# ready to run C code.
		# C is very relaxed in its requirements: All we need to do is
		# to set up the stack.
		# Please note that on x86, the stack grows DOWNWARD. This is
		# why we _start at the top.
		mov $stack_top, %esp # Set the stack pointer to the top of the stack

		# This is a good place to initialize crucial processor state before the
		# high-level kernel is entered. It's best to minimize the early
		# environment where crucial features are offline. Note that the
		# processor is not fully initialized yet: Features such as floating
		# point instructions and instruction set extensions are not initialized
		# yet. The GDT should be loaded here. Paging should be enabled here.
		# C++ features such as global constructors and exceptions will require
		# runtime support to work as well.

		# Now we have a C-worthy (haha!) environment ready to run the
		# rest of our kernel.
		# At this point, we can call our main C function.
		call kernel_main

		# If, by some mysterious circumstances, the kernel's C code
		# ever returns, all we want to do is to hang the CPU
		hang:
			cli      # Disable CPU interrupts
			hlt      # Halt the CPU
			jmp hang # If that didn't work, loop around and try again.

# Set the size of the _start symbol to the current location '.' minus its _start.
# This is useful when debugging or when you implement call tracing.
.size _start, . - _start
