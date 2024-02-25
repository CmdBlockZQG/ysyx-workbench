#include "common.h"
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

  // reset for 20 clock cycle
  top->rstn = 0;
  int n = 20;
  while (n--) {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
  }
  top->rstn = 1;
}

void init_wave(const char *filename) {
  if (!filename) return;
  Verilated::traceEverOn(true);
  trace_file = new VerilatedVcdC;
  top->trace(trace_file, 99);
  trace_file->open(filename);

  Log("Wave is dumped to %s", filename);
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
