#include "driver.h"

#include <cstdio>
#include <cstdlib>
#include <getopt.h>

void init_log(const char *log_file);
void sdb_set_batch_mode();

static char *log_file = nullptr;
static char *img_file = nullptr;

static long load_img() {
  if (!img_file) {

  }
}

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch", no_argument      , NULL, 'b'},
    {"log"  , required_argument, NULL, 'l'},
    {"help" , no_argument      , NULL, 'h'},
    {0      , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bh", table, NULL)) != -1 ) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'l': log_file = optarg; break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch           run with batch mode\n");
        printf("\t-l,--log=FILE        output log to FILE\n");
        printf("\t-h,--help            display this information\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

int main(int argc, char *argv[]) {
  /* parge command line arguments */
  parse_args(argc, argv);
  
  /* open log file */
  init_log(log_file);

  /* init npc verilator module */
  init_top(argc, argv);

  /* init wave file */
  init_wave("top.vcd");

  /* init nvboard */
  init_nvboard();

  /* finalize driver */
  finalize_driver();
}
