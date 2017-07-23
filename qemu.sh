#!/bin/sh

set -e
# shellcheck disable=SC1091
. ./iso.sh

qemu-system-"$(./target-triplet-to-arch.sh "$HOST")" \
	-vga virtio -boot order=d -enable-kvm -m 2048 -smp 2 -soundhw hda \
	-machine type=pc,accel=kvm -show-cursor -usbdevice tablet \
	-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
	-net nic -net bridge,br=virbr0 -monitor stdio -monitor pty \
	-cdrom i686_elf_os.iso
