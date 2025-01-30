AM_SRCS := riscv/rvemu/start.S \
           riscv/rvemu/trm.c \
           riscv/rvemu/ioe.c \
           riscv/rvemu/timer.c \
           riscv/rvemu/input.c \
           riscv/rvemu/cte.c \
           riscv/rvemu/trap.S \
           riscv/rvemu/vme.c \
           riscv/rvemu/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
						 --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/rvemu/include
.PHONY: $(AM_HOME)/am/src/riscv/rvemu/trm.c run

RVEMUFLAGS += --log=$(shell dirname $(IMAGE).elf)

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	@echo run
	$(MAKE) -C $(RVEMU_HOME) ARGS="$(RVEMUFLAGS)" IMG=$(IMAGE).bin ELF=$(IMAGE).elf run
