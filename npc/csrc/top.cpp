#include <cstdio>
#include <cassert>
#include <cstdlib>
#include <ctime>

#include "verilated_vcd_c.h"
#include "Vtop.h"

int main(int argc, char **argv) {
  // init
  VerilatedContext* contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);

  // create module
  Vtop *top = new Vtop{contextp};

  // enable trace
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("top.vcd");

  srand(time(0));
  int cnt = 0;
  while (!contextp->gotFinish() && ++cnt <= 100) {
    contextp->timeInc(1);

    int a = rand() & 1;
    int b = rand() & 1;
    top->a = a;
    top->b = b;
    top->eval();

    printf("a = %d, b = %d, f = %d\n", a, b, top->f);
    tfp->dump(contextp->time());
    assert(top->f == (a ^ b));
  }

  tfp->close();

  delete top;
  delete contextp;
  return 0;
}
