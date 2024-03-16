#include "common.h"
#include "cpu.h"
#include "mem.h"
#include "trace.h"

addr_t cpu_pc = 0x80000000;

static uint64_t nr_inst = 0;
bool trace_enabled = true;

static void statistic() {
  Log("total instructions = %lu", nr_inst);
}

void assert_fail_msg() {
  IFDEF(ITRACE, print_iringbuf());
  reg_display();
  statistic();
}

static void exec_once() {
  extern bool exec_once_flag;
  exec_once_flag = false;
  while (true) {
    top->clk = 0; driver_step();
    top->clk = 1; driver_step();
    if (exec_once_flag) break;
  }
}

static void wp_and_difftest() {
  IFDEF(DIFFTEST, difftest_step());
#ifdef WATCHPOINT
  bool check_wps(void);
  if (check_wps()) {
    if (npc_state.state == NPC_RUNNING) npc_state.state = NPC_STOP;
  }
#endif
}

static void execute(uint64_t n) {
  while (n--) {

#ifdef ITRACE
    itrace(cpu_pc, top->top->inst, n <= 24);
#endif
#ifdef FTRACE
    ftrace(cpu_pc, top->top->pc);
#endif

    exec_once();
    ++nr_inst;
    wp_and_difftest();
    if (nr_inst >= MAX_CYCLE) {
      Log("Cycle limit exceed, abort");
      npc_state.state = NPC_ABORT;
      break;
    }
    if (npc_state.state != NPC_RUNNING) break;
  }
}

void cpu_exec(uint64_t n) {
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  execute(n);

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;
    case NPC_END: case NPC_ABORT:
      Log("npc: %s at pc = " FMT_ADDR,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))), npc_state.halt_pc);
      // fall through
    case NPC_QUIT: statistic();
  }
}

void init_cpu() {
  reset_top();
  exec_once();
}
