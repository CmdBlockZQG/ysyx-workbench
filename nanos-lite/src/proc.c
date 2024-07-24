#include <proc.h>

#define MAX_NR_PROC 4

static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
static PCB pcb_boot = {};
PCB *current = NULL;

void switch_boot_pcb() {
  current = &pcb_boot;
}

void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    Log("Hello World from Nanos-lite with arg '%p' for the %dth time!", (uintptr_t)arg, j);
    j ++;
    yield();
  }
}

void context_kload(PCB *pcb, void (*entry)(void *), void *arg) {
  Area stack = { .start = pcb->stack, .end = pcb->stack + STACK_SIZE };
  Context *ctx = kcontext(stack, entry, arg);
  pcb->cp = ctx;
}

void init_proc() {
  switch_boot_pcb();

  Log("Initializing processes...");
  
  context_kload(&pcb[0], hello_fun, (void *)1);

  // void naive_uload(PCB *pcb, const char *filename);
  // naive_uload(NULL, "/bin/dummy");

  // char *const empty[] = { NULL };
  // context_uload(&pcb[0], "/bin/hello", empty, empty);

  char *const argv[] = { "/bin/pal", "--skip", NULL };
  char *const envp[] = { "KEY=VALUE", NULL };
  context_uload(&pcb[1], "/bin/pal", argv, envp);
}

void create_tmp_context(PCB *pcb) {
  Context *tmp_ctx = (void *)pcb->stack;
  tmp_ctx->pdir = pcb->as.ptr;
  tmp_ctx->GPRx = (uintptr_t)pcb->cp;
  tmp_ctx->mepc = 0; // sign
}

Context* schedule(Context *prev) {
  current->cp = prev;
  create_tmp_context(current);
  current = current == &pcb[1] ? &pcb[0] : &pcb[1];
  return (Context *)current->stack;
}
