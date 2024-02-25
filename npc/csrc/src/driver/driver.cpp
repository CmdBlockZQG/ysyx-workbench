#include "driver.h"

#include "verilated_vcd_c.h"
#include "nvboard.h"
#include "Vtop.h"
#include "Vtop__Dpi.h"

Vtop *top;

static VerilatedContext *contextp;
static VerilatedVcdC *trace_file;
static bool nvboard = false;

void init_top(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new Vtop{contextp};
}

void init_wave(const char *filename) {
  Verilated::traceEverOn(true);
  trace_file = new VerilatedVcdC;
  top->trace(trace_file, 99);
  trace_file->open(filename);
}

void init_nvboard() {
  nvboard = true;

  void nvboard_bind_all_pins(Vtop*);
  nvboard_bind_all_pins(top);

  nvboard_init();
}

void finalize_driver() {
  if (trace_file) trace_file->close();
  delete top;
  delete contextp;
}

void driver_step() {
  top->eval();
  if (nvboard) nvboard_update();
  contextp->timeInc(1);
  if (trace_file) trace_file->dump(contextp->time());
}
