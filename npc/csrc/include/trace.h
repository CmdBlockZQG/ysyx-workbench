#ifndef __TRACE_H__
#define __TRACE_H__

#include "common.h"

void itrace(addr_t pc, uint64_t inst, bool print);
void print_iringbuf();

#endif