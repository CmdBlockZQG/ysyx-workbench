ENABLE_YSYXSOC ?= 0
ifeq ($(ENABLE_YSYXSOC), 1)
TOPNAME = ysyxSoCFull
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(abspath ../ysyxSoC/build/ysyxSoCFull.v)
INCDIR += "$(abspath ../ysyxSoC/perip/uart16550/rtl)"
INCDIR += "$(abspath ../ysyxSoC/perip/spi/rtl)"
CXXFLAGS += -DYSYXSOC=1
else
TOPNAME = ysyx_23060203_CPU
endif

NXDC_FILES = constr/top.nxdc
INC_PATH = $(abspath ./csrc/include)

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
					-O3 --x-assign fast --x-initial fast --noassert
VERILATOR_FLAGS = --timescale "1ns/1ns" --no-timing --autoflush

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
override ARGS += --nvboard
CXXFLAGS += -DNVBOARD=1
endif


$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -y , $(INCDIR)) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) \
		$(VERILATOR_FLAGS)

default: $(BIN)

all: default

clean:
	rm -rf $(BUILD_DIR)


ARGS ?= --log=$(BUILD_DIR)/log.txt
# override ARGS += --wave=$(BUILD_DIR)/wave.vcd
IMG ?=
ifdef ELF
override ARGS += --elf=$(ELF)
endif
override ARGS += --diff=$(NEMU_HOME)/build/riscv32-nemu-interpreter-so

sim: $(BIN)
	$(call git_commit, "sim RTL")
	$(BIN) $(ARGS) $(IMG)

run: $(BIN)
	$(call git_commit, "sim RTL")
	$(BIN) $(ARGS) $(IMG)

wave:
	@sed '4,8d' $(BUILD_DIR)/wave.vcd | sed -E '/^ {1,5}\$upscope \$end/d' > $(BUILD_DIR)/wave-tmp.vcd
	@rm $(BUILD_DIR)/wave.vcd
	@mv $(BUILD_DIR)/wave-tmp.vcd $(BUILD_DIR)/wave.vcd

.PHONY: default all clean sim run wave

include ../Makefile
