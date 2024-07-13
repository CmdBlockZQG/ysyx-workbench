#include "macro.h"
#include "perf.h"

#ifdef YSYXSOC
#include "VysyxSoCFull__Dpi.h"
#else
#include "Vysyx_23060203__Dpi.h"
#endif

// READY : 单元完成当前任务，发出ready信号请求上游供给
// CPLT  : 完成 complete 的缩写

static const char *perfcnt_name[] = {
  "IFU_WAIT",
  "IFU_INST",
  "IFU_HOLD",

  "ICACHE_HIT",
  "ICACHE_MISS",
  "ICACHE_MEM",

  "IDU_IDLE",
  "IDU_INST",
  "IDU_HOLD",

  "EXU_IDLE",
  "EXU_INST",
  "EXU_HOLD",
  "EXU_FLUSH",
  "EXU_MEMR",
  "EXU_MEMW",

  "WBU_IDLE",
  "WBU_INST"
};

const int perfcnt_num = ARRLEN(perfcnt_name);

static uint64_t perfcnt_val[perfcnt_num] = {0};

void perf_event(int id) {
  perfcnt_val[id] += 1;
}

void log_perf_stat() {
  for (int i = 0; i < perfcnt_num; ++i) {
    log_write("%-20s\t%15lu\n", perfcnt_name[i], perfcnt_val[i]);
  }
}
