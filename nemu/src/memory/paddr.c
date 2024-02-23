/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

#ifdef CONFIG_MTRACE
void locate_object_sym(paddr_t addr) {
  extern ElfSymbol elf_symbol_list[];
  extern word_t elf_symbol_list_size;
  for (word_t i = 0; i < elf_symbol_list_size; ++i) {
    if (elf_symbol_list[i].type == ELF_SYM_OBJECT &&
        elf_symbol_list[i].addr <= addr &&
        addr < elf_symbol_list[i].addr + elf_symbol_list[i].size) {
      paddr_t off = addr - elf_symbol_list[i].addr;
      if (off) {
        log_write("(%s + %u)", elf_symbol_list[i].name, (uint32_t)off);
      } else {
        log_write("(%s)", elf_symbol_list[i].name);
      }
      return;
    }
  }
}
#endif

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) {
#ifdef CONFIG_MTRACE
    if (CONFIG_MTRACE_START <= addr && addr <= CONFIG_MTRACE_END) {
      log_write("[MTRACE] Read %d bytes at " FMT_PADDR, len, addr);
      locate_object_sym(addr);
      log_write("\n");
    }
#endif
    return pmem_read(addr, len);
  }
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) {
#ifdef CONFIG_MTRACE
    if (CONFIG_MTRACE_START <= addr && addr <= CONFIG_MTRACE_END) {
      log_write("[MTRACE] Write %d bytes at " FMT_PADDR , len, addr);
      locate_object_sym(addr);
      log_write(": " FMT_WORD "\n", data);
    }
#endif
    pmem_write(addr, len, data);
    return; 
  }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
