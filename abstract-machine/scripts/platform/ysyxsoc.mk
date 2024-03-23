AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/ioe.c \
           riscv/ysyxsoc/timer.c \
           riscv/ysyxsoc/input.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/am/src/riscv/ysyxsoc/linker.ld
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/ysyxsoc/include
.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c run

NPCFLAGS += --log=$(shell dirname $(IMAGE).elf)/ysyxsoc-log.txt --batch

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	@echo run
	$(MAKE) -C $(NPC_HOME) ARGS="$(NPCFLAGS)" IMG=$(IMAGE).bin ELF=$(IMAGE).elf run
