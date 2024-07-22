#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);
void __libc_init_array();
extern char **environ;
void call_main(uintptr_t *args) {

  // int argc = *args++;
  // printf("%d argv: \n", argc);
  // for (int i = 0; i < argc; ++i) {
  //   printf("%s\n", (char *)*args++);
  // }
  // assert(*args++ == 0);
  // printf("envp: \n");
  // while (*args) {
  //   printf("%s\n", (char *)*args++);
  // }
  for (int i = 0; i < 6; ++i) {
    printf("%p\n", *args);
    args += 1;
  }

  char *empty[] =  {NULL };
  environ = empty;
  __libc_init_array();
  exit(main(0, empty, empty));
  assert(0);
}
