#include "common.h"

#include <readline/readline.h>
#include <readline/history.h>

static bool is_batch_mode = false;

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = nullptr;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "si N: Execute N instructions and then pause, N = 1 if not given", cmd_si },
  { "info", "info r/w: Print register/watchpoint info", cmd_info },
  { "x", "x N EXPR: Evaluate EXPR, print N*4 bytes starting from the address", cmd_x },
  { "p", "p EXPR: Evaluate EXPR", cmd_p },
  { "w", "w EXPR: Stop when value of EXPR changes(watchpoint)", cmd_w },
  { "d", "d N: Delete watchpoint No.N", cmd_d },
};


void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void init_sdb() {

}
