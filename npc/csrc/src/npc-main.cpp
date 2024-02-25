#include "common.h"
#include "driver.h"
#include "mem.h"

#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <getopt.h>

void init_log(const char *log_file);
void init_elf(const char *elf_file);
void init_mem();
void init_sdb();
void sdb_set_batch_mode();
int is_exit_status_bad();
void sdb_mainloop();

static char *log_file = nullptr;
static char *img_file = nullptr;
static char *elf_file = nullptr;

static void load_img() {
  if (!img_file) {
    const uint32_t img[] = {
      0x00500093, // addi x1, x0, 5
      0x00608113, // addi x2, x1, 6
      0x00310093, // addi x1, x2, 3
      0x00108093, // addi x1, x1, 1
      0x00100073, // ebreak
      0xdeadbeef  // some data
    };
    memcpy(guest_to_host(MBASE), img, sizeof(img));
    Log("No image is given. Use the default built-in image.");
    return;
  }
  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open image file '%s'", img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("Image file %s, size = %ld", img_file, size);

  fseek(fp, 0, SEEK_SET);
  Assert(fread(guest_to_host(MBASE), size, 1, fp) == 1, "Error when reading image file");

  fclose(fp);
}

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"  , no_argument      , NULL, 'b'},
    {"log"    , required_argument, NULL, 'l'},
    {"elf"    , required_argument, NULL, 'e'},
    {"wave"   , required_argument, NULL, 'w'},
    {"nvboard", no_argument      , NULL, 'n'},
    {"help"   , no_argument      , NULL, 'h'},
    {0        , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bh", table, NULL)) != -1 ) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'l': log_file = optarg; break;
      case 'e': elf_file = optarg; break;
      case 'w': init_wave(optarg); break;
      case 'n': init_nvboard(); break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch           run with batch mode\n");
        printf("\t-l,--log=FILE        output log to FILE\n");
        printf("\t-e,--elf=FILE        load elf file from FILE\n");
        printf("\t-w,--wave=FILE       dump wave to FILE\n");
        printf("\t-n,--nvboard         run nvboard\n");
        printf("\t-h,--help            display this information\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

int main(int argc, char *argv[]) {
  /* init npc verilator module */
  init_top(argc, argv);

  /* parge command line arguments */
  parse_args(argc, argv);

  /* open log file */
  init_log(log_file);

  /* initialize memory */
  init_mem();

  /* load image */
  load_img();

  /* load elf file */
  init_elf(elf_file);

  /* initialize simple debugger */
  init_sdb();

  /* finalize driver */
  finalize_driver();

  /* run sdb */
  sdb_mainloop();

  // TODO: init_disasm

  return is_exit_status_bad();
}
