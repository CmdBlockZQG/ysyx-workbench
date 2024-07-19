#include <am.h>

Area heap;

extern int _syscall_(int, uintptr_t, uintptr_t, uintptr_t);

void putch(char ch) {
  _syscall_(4, 0, (uintptr_t)&ch, 1);
}

void halt(int code) {
  _syscall_(0, code, 0, 0);
  while (1);
}
