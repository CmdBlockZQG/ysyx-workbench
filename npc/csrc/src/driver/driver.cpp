#include "debug.h"
#include "driver.h"

#include "verilated_vcd_c.h"
#include "nvboard.h"
#include "VysyxSoCFull.h"

VysyxSoCFull *top_module;

static VerilatedContext *contextp;
static VerilatedVcdC *trace_file;
static bool nvboard = false;

void init_top(int argc, char **argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top_module = new VysyxSoCFull(contextp, "top");
}

void init_wave(const char *filename) {
  if (!filename) return;
  Verilated::traceEverOn(true);
  trace_file = new VerilatedVcdC;
  // top_module->trace(trace_file, 1);
  trace_file->dumpvars(0, "top");
  trace_file->open(filename);

  Log("Wave is dumped to %s", filename);
}

void init_nvboard() {
  nvboard = true;

  void nvboard_bind_all_pins(VysyxSoCFull*);
  nvboard_bind_all_pins(top_module);

  nvboard_init();
}

void finalize_driver() {
  if (trace_file) trace_file->close();
  delete top_module;
  delete contextp;
}

void driver_step() {
  top_module->eval();
  if (nvboard) nvboard_update();
  contextp->timeInc(1);
  if (trace_file) trace_file->dump(contextp->time());
}

void reset_top() {
  // reset for 20 clock cycle
  top_module->reset = 1;
  int n = 20;
  while (n--) {
    top_module->clock = 0; top_module->eval(); // driver_step();
    top_module->clock = 1; top_module->eval(); // driver_step();
  }
  top_module->reset = 0;
}
