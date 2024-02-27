#include "common.h"
#include "driver.h"
#include "mem.h"

static uint64_t nr_inst = 0;
bool trace_enabled = true;

static void statistic() {
  Log("total instructions = %lu", nr_inst);
}

void assert_fail_msg() {
  statistic();
}

static void exec_once() {
  top->clk = 0; driver_step();
  top->clk = 1; driver_step();
}

static void trace_and_difftest() {
  // TODO: trace & watchpoint & difftest
}

static void execute(uint64_t n) {
  while (n--) {
    exec_once();
    ++nr_inst;
    trace_and_difftest();
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
      Log("npc: %s",
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))));
      // fall through
    case NPC_QUIT: statistic();
  }
}
