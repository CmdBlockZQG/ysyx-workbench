AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/bootloader.c \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/input.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           riscv/ysyxsoc/ioe/ioe.c \
           riscv/ysyxsoc/ioe/uart.c \
           riscv/ysyxsoc/ioe/timer.c \
           riscv/ysyxsoc/ioe/gpio.c \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/am/src/riscv/ysyxsoc/linker.ld
LDFLAGS   += --gc-sections -e _fsbl # --orphan-handling=warn --print-map
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/ysyxsoc/include
.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c run run_bd

NPCFLAGS += --log=$(shell dirname $(IMAGE).elf)/ysyxsoc-log.txt --batch

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	@echo run
	$(MAKE) -C $(NPC_HOME) ARGS="$(NPCFLAGS)" IMG=$(IMAGE).bin ELF=$(IMAGE).elf run

run_bd: image
	@echo run_bd
	$(MAKE) -C $(NPC_HOME) ARGS="$(NPCFLAGS) --nvboard" IMG=$(IMAGE).bin ELF=$(IMAGE).elf run
