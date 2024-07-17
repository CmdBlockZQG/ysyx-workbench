include $(AM_HOME)/scripts/isa/riscv.mk
include $(AM_HOME)/scripts/platform/ysyxsoc.mk
CFLAGS  += -DISA_H=\"riscv/riscv.h\"
COMMON_CFLAGS += -march=rv32em_zicsr_zifencei -mabi=ilp32e  # overwrite
LDFLAGS       += -melf32lriscv                    # overwrite
