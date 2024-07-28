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
  "IFU_FETCH",       // IFU取到指令
  "IFU_WAIT_MEM",    // IFU因访存延迟等待
  "IFU_WAIT_EXU",    // IFU因指令执行等待

  "IDU_UPIMM",       // 译码 LUI AUIPC
  "IDU_JUMP",        // 译码无条件跳转 JAL JALR
  "IDU_BRANCH",      // 译码分支 BXX
  "IDU_LOAD",        // 译码加载 LXX
  "IDU_STORE",       // 译码储存 SXX
  "IDU_CALRI",       // 译码 寄存器-立即数 整数计算 XXI
  "IDU_CALRR",       // 译码 寄存器-寄存器 整数计算 XXX
  "IDU_SYS",        // 译码SYS指令 ECALL EBREAK
  "IDU_CSR",        // 译码CSR指令 CSRXX

  "EXU_UPIMM",      // 执行 LUI AUIPC
  "EXU_JUMP",       // 执行无条件跳转 JAL JALR
  "EXU_BRANCH",     // 执行分支 BXX
  "EXU_LOAD",       // 执行加载 LXX
  "EXU_STORE",      // 执行储存 SXX
  "EXU_CALRI",      // 执行 寄存器-立即数 整数计算 XXI
  "EXU_CALRR",      // 执行 寄存器-寄存器 整数计算 XXX
  "EXU_SYS",        // 执行SYS指令 ECALL EBREAK
  "EXU_CSR",        // 执行CSR指令 CSRXX
  "EXU_READY",      // EXU完成计算

  "LSU_LOAD",       // LSU取数据ing
  "LSU_LOAD_RESP",  // LSU取到数据
  "LSU_STORE",      // LSU存数据ing

  "ICACHE_HIT",     // 指令缓存命中
  "ICACHE_MISS",    // 指令缓存缺失
  "ICACHE_WAIT_MEM" // 指令缓存缺失，等待存储器
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
