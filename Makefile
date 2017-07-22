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
TARGET_ARCH ?= -march=i686 -mtune=generic
CFLAGS := -ffreestanding -Wall -Wextra -std=c11 -pedantic-errors
LDFLAGS := $(CFLAGS) -nostdlib -T linker.ld -Wl,-O1,-zrelro,-znow,--sort-common,--as-needed
LDLIBS := -lgcc
DEBUG := -Og -ggdb -pipe
RELEASE := -O2 -pipe

TARGET := i686-elf-os.elf
OBJ := kernel.o start.o
GRUB_DIR := isoroot
ISO := $(patsubst %.elf, %.iso, $(TARGET))

all: CFLAGS += $(RELEASE)
all: LDFLAGS += $(RELEASE)
all: $(TARGET) iso

debug: CFLAGS += $(DEBUG)
debug: LDFLAGS += $(DEBUG)
debug: $(TARGET) iso

iso: $(TARGET)
	@cp -v $(TARGET) $(GRUB_DIR)/boot/
	grub-mkrescue $(GRUB_DIR) -o $(ISO)

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $(LDLIBS) $(TARGET_ARCH) $(OBJ) -o $@

kernel.o:
	$(CC) $(CFLAGS) $(TARGET_ARCH) -c kernel.c -o $@

start.o:
	$(CC) $(CFLAGS) $(TARGET_ARCH) -c start.s -o $@

clean:
	@printf "%s\n" "cleaning"
	@rm -fv $(TARGET) $(ISO) $(OBJ) $(GRUB_DIR)/boot/$(TARGET)

.PHONY: all clean
