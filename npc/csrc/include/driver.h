#ifndef __DRIVER_H__
#define __DRIVER_H__

#include "VysyxSoCFull.h"
#include "VysyxSoCFull_CPU.h"
#include "VysyxSoCFull_ysyxSoCASIC.h"
#include "VysyxSoCFull_ysyxSoCFull.h"
#include "VysyxSoCFull_ysyx_23060203.h"
#include "VysyxSoCFull_ysyx_23060203_CPU.h"

extern VysyxSoCFull *top_module;

#define cpu_module top_module->ysyxSoCFull->asic->cpu->cpu->NPC_CPU

void init_top(int argc, char **argv);
void init_wave(const char *filename);
void init_nvboard();
void driver_cycle();
void finalize_driver();
void reset_top();

#endif
