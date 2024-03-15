#ifndef __DRIVER_H__
#define __DRIVER_H__

#include "Vtop.h"

extern Vtop *top;

void init_top(int argc, char **argv);
void init_wave(const char *filename);
void init_nvboard();
void driver_step();
void finalize_driver();
void reset_top();

#endif
