#include <cstdio>
#include <cassert>
#include <cstdlib>
#include <ctime>

#include "verilated_vcd_c.h"
#include "Vtop.h"

void nvboard_bind_all_pins(Vtop*);

static VerilatedContext *contextp;
static Vtop *top;
static VerilatedVcdC *trace_file;

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

void finalize() {
  if (trace_file) trace_file->close();
  delete top;
  delete contextp;
}

bool is_finished() {
  return contextp->gotFinish();
}

void step() {
  contextp->timeInc(1);
  if (trace_file) trace_file->dump(contextp->time());
}

int main(int argc, char **argv) {
  init_top(argc, argv);

  // init_trace("top.vcd");

  srand(time(0));
  int cnt = 0;
  while (!is_finished() && ++cnt <= 100) {
    int a = rand() & 1;
    int b = rand() & 1;
    top->a = a;
    top->b = b;
    top->eval();

    printf("a = %d, b = %d, f = %d\n", a, b, top->f);
    assert(top->f == (a ^ b));

    step();
  }

  finalize();
  return 0;
}
