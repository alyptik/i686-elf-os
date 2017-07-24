#
# i686-elf-os - a toy x86 operating system implementation
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

CC := i686-elf-gcc
LD := $(CC)
PREFIX ?= $(DESTDIR)/usr/local
CFLAGS := -ffreestanding -std=c11 -Wall -Wextra -pedantic-errors
LDFLAGS := $(CFLAGS) -nostdlib -T linker.ld -Wl,-O1,-zrelro,-znow,--sort-common,--as-needed
LIBS := -lgcc
DEBUG := -Og -ggdb -pipe
RELEASE := -O2 -pipe

.PHONY: all debug clean

all: CFLAGS += $(RELEASE)
all: LDFLAGS += $(RELEASE)
all: clean
	./build.sh
	./qemu.sh

debug: CFLAGS += $(DEBUG)
debug: LDFLAGS += $(DEBUG)
debug: clean
	./build.sh
	./qemu.sh

clean:
	@printf "%s\n" "cleaning"
	./clean.sh
