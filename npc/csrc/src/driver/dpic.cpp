#include "Vtop__Dpi.h"
#include "common.h"

void halt() {
  set_npc_state(NPC_END, 0); // TODO: read reg a0 as ret
}
