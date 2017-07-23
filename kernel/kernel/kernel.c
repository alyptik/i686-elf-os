/*
 * kernel.c - the majority of our kernel, written in C
 *
 * Copyright 2017 Joey Pabalinas <alyptik@protonmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>

#include <kernel/tty.h>

void kernel_main(void)
{
	terminal_initialize();

	/* Display some messages */
	terminal_writestring("Hello, World!\n");
	terminal_writestring("Welcome to the kernel.\n");

}
