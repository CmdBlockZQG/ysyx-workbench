#include "macro.h"
#include "perf.h"

#ifdef YSYXSOC
#include "VysyxSoCFull__Dpi.h"
#else
#include "Vysyx_23060203__Dpi.h"
#endif

static const char *perfcnt_name[] = {
  "IFU_WAIT", // IFU等待指令读取周期数
  "IFU_INST", // IFU提供指令次数
  "IFU_HOLD", // IFU提供指令周期数

  "ICACHE_MISS", // ICache缺失次数
  "ICACHE_MEM",  // ICache等待存储器周期数

  "IDU_IDLE", // IDU空闲周期数
  "IDU_INST", // IDU提供指令次数
  "IDU_HOLD", // IDU提供指令周期数

  "IDU_LOAD",    // IDU译码LOAD指令
  "IDU_STORE",  // IDU译码STORE指令
  "IDU_BRANCH", // IDU译码BRANCH指令
  "IDU_JAL",    // IDU译码JAL指令
  "IDU_JALR",   // IDU译码JALR指令

  "EXU_IDLE",  // EXU空闲周期数
  "EXU_INST",  // EXU执行指令数量
  "EXU_FLUSH", // EXU冲刷上游流水级次数

  "LSU_MEMR",  // LSU读内存周期数
  "LSU_MEMW",  // LSU写内存周期数
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
