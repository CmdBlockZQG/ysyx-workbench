ENABLE_YSYXSOC ?= 1
ARGS ?= --log=$(BUILD_DIR)/log.txt

ifeq ($(ENABLE_YSYXSOC), 1)
TOPNAME = ysyxSoCFull
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(abspath ../ysyxSoC/build/ysyxSoCFull.v)
INCDIR += "$(abspath ../ysyxSoC/perip/uart16550/rtl)"
INCDIR += "$(abspath ../ysyxSoC/perip/spi/rtl)"
CXXFLAGS += -DYSYXSOC=1
VERILATOR_FLAGS += -DYSYXSOC=1
override ARGS += --diff=$(NEMU_HOME)/build/riscv32-nemu-interpreter-so-ysyxsoc
else
TOPNAME = ysyx_23060203
override ARGS += --diff=$(NEMU_HOME)/build/riscv32-nemu-interpreter-so
endif

NXDC_FILES = constr/top.nxdc
INC_PATH = $(abspath ./csrc/include)

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
					-O3 --x-assign fast --x-initial fast --noassert
VERILATOR_FLAGS += --timescale "1ns/1ns" --no-timing --autoflush

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

$(shell mkdir -p $(BUILD_DIR))

# project source
VSRCS += $(shell find $(abspath ./vsrc) -name "*.sv")
CSRCS += $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
INCDIR += "$(abspath ./vsrc)"

# rules for verilator
INCFLAGS = $(addprefix -I , $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -Wall -Werror \
					  -DTOP_NAME="\"V$(TOPNAME)\"" \
						-fmacro-prefix-map=/home/cmdblock/ysyx/ysyx-workbench/npc/csrc=

# rules for llvm disasm
CXXFLAGS += $(shell llvm-config --cxxflags) -fPIE
LDFLAGS += $(shell llvm-config --libs)

LDFLAGS += -lreadline

# NVBoard
ENABLE_NVBOARD ?= 0
ifeq ($(ENABLE_NVBOARD), 1)
include $(NVBOARD_HOME)/scripts/nvboard.mk
# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@
CSRCS += $(SRC_AUTO_BIND)
CXXFLAGS += -DNVBOARD=1
endif


$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) $(shell find $(abspath ./csrc) -name "*.h")
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) \
		$(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) \
		$(addprefix -y , $(INCDIR)) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) \
		$(VERILATOR_FLAGS)

default: $(BIN)

all: default

clean:
	rm -rf $(BUILD_DIR)

# override ARGS += --wave=$(BUILD_DIR)/wave.vcd
override ARGS += --pctrace=$(BUILD_DIR)/pctrace
IMG ?=
ifdef ELF
override ARGS += --elf=$(ELF)
endif

sim: $(BIN)
	$(call git_commit, "sim RTL")
	$(BIN) $(ARGS) $(IMG)

run: $(BIN)
	$(call git_commit, "sim RTL")
	@git rev-parse HEAD
	$(BIN) $(ARGS) $(IMG)

sta:
	make -C /home/cmdblock/ysyx/yosys-sta/ sta
	grep "Chip area for" ~/ysyx/yosys-sta/result/ysyx_23060203-700MHz/synth_stat.txt

merge:
	@cat $(shell find $(abspath ./vsrc) -name "*.sv") > build/ysyx_23060203.sv

.PHONY: default all clean sim run sta merge

include ../Makefile
