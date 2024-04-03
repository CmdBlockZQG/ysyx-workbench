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
void init_cpu();
void init_difftest(char *ref_so_file, long img_size);
void init_sdb();
void sdb_set_batch_mode();
int is_exit_status_bad();
void sdb_mainloop();
void init_disasm(const char *triple);

static char *log_file = nullptr;
static char *img_file = nullptr;
static char *elf_file = nullptr;
static char *wave_file = nullptr;
static char *diff_so_file = nullptr;

static long load_img() {
  long ret;
  if (!img_file) {
    const uint32_t img[] = {
      0x100007b7,
      0xf8300713,
      0x00e781a3,

      0x00500093, // addi x1, x0, 5
      0x008002ef, // jal x5, 8
      0x00608113, // addi x2, x1, 6
      0x00310093, // addi x1, x2, 3
      0x00108093, // addi x1, x1, 1
      0x00100073, // ebreak
      0xdeadbeef  // some data
    };
    memcpy(guest_to_host(MROM_BASE), img, sizeof(img));
    Log("No image is given. Use the default built-in image.");
    ret = 4096;
  } else {
    FILE *fp = fopen(img_file, "rb");
    Assert(fp, "Can not open image file '%s'", img_file);

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);

    Log("Image file %s, size = %ld", img_file, size);

    fseek(fp, 0, SEEK_SET);
    Assert(fread(guest_to_host(MROM_BASE), size, 1, fp) == 1, "Error when reading image file");

    fclose(fp);
    ret = size;
  }
  return ret;
}

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"  , no_argument      , NULL, 'b'},
    {"log"    , required_argument, NULL, 'l'},
    {"elf"    , required_argument, NULL, 'e'},
    {"wave"   , required_argument, NULL, 'w'},
    {"diff"   , required_argument, NULL, 'd'},
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
      case 'w': wave_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 'n': init_nvboard(); break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch           run with batch mode\n");
        printf("\t-l,--log=FILE        output log to FILE\n");
        printf("\t-e,--elf=FILE        load elf file from FILE\n");
        printf("\t-w,--wave=FILE       dump wave to FILE\n");
        printf("\t-d,--diff=REF_SO     run DiffTest with reference REF_SO\n");
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

  /* initialize wave output */
  init_wave(wave_file);

  /* initialize memory */
  init_mem();

  /* load image */
  long img_size = load_img();

  /* reset cpu */
  init_cpu();

  /* load elf file */
  IFDEF(ELF, init_elf(elf_file));

  /* initialize llvm disasm */
  IFDEF(ITRACE, init_disasm(MUXDEF(RV64, "riscv64", "riscv32") "-pc-linux-gnu"));

  /* initialize differential testing */
  init_difftest(diff_so_file, img_size);

  /* initialize simple debugger */
  init_sdb();

  /* run sdb */
  sdb_mainloop();

  /* finalize driver */
  finalize_driver();

  return is_exit_status_bad();
}
