#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/i686_elf_os.kernel isodir/boot/i686_elf_os.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "i686_elf_os" {
	multiboot /boot/i686_elf_os.kernel
}
EOF
grub-mkrescue -o i686_elf_os.iso isodir
