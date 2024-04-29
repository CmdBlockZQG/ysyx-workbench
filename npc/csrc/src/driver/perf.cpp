#include "macro.h"
#include "utils.h"

#ifdef YSYXSOC
#include "VysyxSoCFull__Dpi.h"
#else
#include "Vysyx_23060203__Dpi.h"
#endif

// READY : 单元完成当前任务，发出ready信号请求上游供给
// CPLT  : 完成 complete 的缩写

static const char *perfcnt_name[] = {
  "IFU_FETCH",      // IFU取到指令
  "LSU_LOAD_RESP",  // LSU取到数据
  "EXU_READY",      // EXU完成计算
  "IDU_LUI",        // 译码 LUI
  "IDU_AUIPC",      // 译码 AUIPC
  "IDU_JUMP",       // 译码无条件跳转 JAL JALR
  "IDU_BRANCH",     // 译码分支 BXX
  "IDU_LOAD",       // 译码加载 LXX
  "IDU_STORE",      // 译码储存 SXX
  "IDU_CALRI",      // 译码 寄存器-立即数 整数计算 XXI
  "IDU_CALRR",     // 译码 寄存器-寄存器 整数计算 XXX
  "IDU_SYS",       // 译码SYS指令 ECALL EBREAK
  "IDU_CSR"        // 译码CSR指令 CSRXX
};

const int perfcnt_num = ARRLEN(perfcnt_name);

static int perfcnt_val[perfcnt_num] = {0};

void perf_event(int id) {
  perfcnt_val[id] += 1;
}

void log_perf_stat() {
  log_write("---------- Performce Counter ----------\n");
  for (int i = 0; i < perfcnt_num; ++i) {
    log_write("%s\t\t%d\n", perfcnt_name[i], perfcnt_val[i]);
  }
}
