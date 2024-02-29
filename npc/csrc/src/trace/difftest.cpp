#include "common.h"
#include "mem.h"
#include "cpu.h"

#include <dlfcn.h>

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
#define NR_GPR MUXDEF(RVE, 16, 32)
struct diff_context_t {
  word_t gpr[NR_GPR];
  word_t pc;
};

void (*ref_difftest_memcpy)(addr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;

#ifdef DIFFTEST

static bool is_skip_ref = false;
static int skip_dut_nr_inst = 0;

void get_dut_ctx(diff_context_t *ctx) {
  for (int i = 0; i < NR_GPR; ++i) {
    ctx->gpr[i] = gpr(i);
  }
  ctx->pc = cpu_pc;
}

void difftest_skip_ref() {
  is_skip_ref = true;
}

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = (void (*)(addr_t addr, void *buf, size_t n, bool direction))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *dut, bool direction))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = (void (*)(uint64_t n))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void (*)(uint64_t NO))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  Log("Differential testing: %s", ANSI_FMT("ON", ANSI_FG_GREEN));
  Log("The result of every instruction will be compared with %s. "
      "This will help you a lot for debugging, but also significantly reduce the performance. "
      "If it is not necessary, you can turn it off in menuconfig.", ref_so_file);

  ref_difftest_init(port);
  ref_difftest_memcpy(MBASE, guest_to_host(MBASE), img_size, DIFFTEST_TO_REF);
  diff_context_t ctx;
  get_dut_ctx(&ctx);
  ref_difftest_regcpy(&ctx, DIFFTEST_TO_REF);
}

static bool checkregs(diff_context_t *ref) {
  for (int i = 0; i < NR_GPR; ++i) {
    if (ref->gpr[i] != gpr(i)) return false;
  }
  return ref->pc == cpu_pc;
}

#endif
