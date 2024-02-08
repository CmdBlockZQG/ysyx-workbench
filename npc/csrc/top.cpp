#include <cstdio>
#include <cassert>
#include <cstdlib>
#include <ctime>

#include "verilated_vcd_c.h"
#include "nvboard.h"
#include "Vtop.h"

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

void step() {
  if (nvboard) nvboard_update();
  contextp->timeInc(1);
  if (trace_file) trace_file->dump(contextp->time());
}

void single_cycle() {
  top->clk = 0; top->eval();
  top->clk = 1; top->eval();
}

void reset(int n) {
  top->rst = 1;
  while (n--) single_cycle();
  top->rst = 0;
}

int main(int argc, char **argv) {
  init_top(argc, argv);

  // init_trace("top.vcd");
  init_nvboard();

  reset(10);
  while (!is_finished()) {
    single_cycle();
    step();
  }

  finalize();
  return 0;
}
