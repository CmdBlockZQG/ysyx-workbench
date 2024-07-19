#include <am.h>
#include <stdlib.h>
#include <unistd.h>

Area heap = {(void *)0x84000000L, (void *)0x85000000L};

extern int _syscall_(int, uintptr_t, uintptr_t, uintptr_t);

void putch(char ch) {
  write(1, &ch, 1);
}

void halt(int code) {
  exit(code);
}
