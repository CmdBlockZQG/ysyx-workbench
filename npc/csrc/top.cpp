#include <cstdio>
#include <cassert>
#include <cstdlib>
#include <ctime>

#include "verilated_vcd_c.h"
#include "nvboard.h"
#include "Vtop.h"
#include "Vtop__Dpi.h"

void nvboard_bind_all_pins(Vtop*);

static VerilatedContext *contextp;
static Vtop *top;
static VerilatedVcdC *trace_file;
static bool nvboard = false;

void init_top(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new Vtop{contextp};
}

void init_trace(const char *filename) {
  Verilated::traceEverOn(true);
  trace_file = new VerilatedVcdC;
  top->trace(trace_file, 99);
  trace_file->open(filename);
}

void init_nvboard() {
  nvboard = true;
  nvboard_bind_all_pins(top);
  nvboard_init();
}

void finalize() {
  if (trace_file) trace_file->close();
  delete top;
  delete contextp;
}

bool is_finished() {
  return contextp->gotFinish();
}

const uint32_t img[] = {
  0x00500093,
  0x00608113,
  0x00310093,
  0x00108093,
  0x00100073
};

void step() {
  uint32_t addr = top->inst_mem_addr - 0x80000000;
  if (addr < sizeof(img)) top->inst_mem_data = img[addr >> 2];
  else top->inst_mem_data = 0;
  top->eval();
  if (nvboard) nvboard_update();
  contextp->timeInc(1);
  if (trace_file) trace_file->dump(contextp->time());
}

void single_cycle() {
  top->clk = 0; step();
  top->clk = 1; step();
}

void reset(int n) {
  top->rstn = 0;
  while (n--) single_cycle();
  top->rstn = 1;
}

static bool halt_sig = false;
int main(int argc, char **argv) {
  init_top(argc, argv);

  init_trace("top.vcd");
  // init_nvboard();

  reset(10);
  while (!halt_sig && !is_finished()) {
    single_cycle();
  }

  finalize();
  return 0;
}

void halt() {
  halt_sig = true;
}
