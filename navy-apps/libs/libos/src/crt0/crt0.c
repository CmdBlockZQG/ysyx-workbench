#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);
void __libc_init_array();
extern char **environ;
void call_main(uintptr_t *args) {

  int argc = *args;
  char **argv = (char **)args + 1;
  char **envp = (char **)args + 1 + argc + 1;

  printf("%d argv: \n", argc);
  for (int i = 0; i < argc; ++i) {
    printf("%s\n", argv[i]);
  }
  assert(argv[argc] == NULL);
  printf("envp: \n");
  for (int i = 0; envp[i]; ++i) {
    printf("%s\n", envp[i]);
  }

  char *empty[] =  {NULL };
  environ = empty;
  __libc_init_array();
  exit(main(0, empty, empty));
  assert(0);
}
