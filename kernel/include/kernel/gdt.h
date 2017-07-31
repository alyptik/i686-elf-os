#ifndef _KERNEL_GDT_H
#define _KERNEL_GDT_H

#include <stddef.h>
#include <stdio.h>
#include <stdint.h>

void create_descriptor(uint32_t base, uint32_t limit, uint16_t flag);
void init_gdt(void);

#endif
