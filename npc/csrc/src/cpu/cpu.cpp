#include "common.h"
#include "driver.h"
#include "memory/paddr.h"

void exec_once() {
  auto eval_inst = [&]() -> void {
    paddr_t iaddr = top->inst_mem_addr;
    top->inst_mem_data = paddr_read(iaddr, 4);
  };
  top->clk = 0; eval_inst(); driver_step();
  top->clk = 1; eval_inst(); driver_step();
}

void trace_and_difftest() {

}

static void execute(uint64_t n) {
  while (n--) {
    exec_once();
    trace_and_difftest();
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
      Log("npc: %s" FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))));
      // fall through
    case NPC_QUIT: // statistic();
  }
}