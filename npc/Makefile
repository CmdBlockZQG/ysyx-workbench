TOPNAME = ysyxSoCFull
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

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.sv")
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(abspath ../ysyxSoC/build/ysyxSoCFull.v)
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)
INCDIR = "$(abspath ./vsrc)"
INCDIR += "$(abspath ../ysyxSoC/perip/uart16550/rtl)"
INCDIR += "$(abspath ../ysyxSoC/perip/spi/rtl)"

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I , $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -Wall -Werror \
					  -DTOP_NAME="\"V$(TOPNAME)\"" \
						-fmacro-prefix-map=/home/cmdblock/ysyx/ysyx-workbench/npc=npc

# rules for llvm disasm
CXXFLAGS += $(shell llvm-config --cxxflags) -fPIE
LDFLAGS += $(shell llvm-config --libs)

LDFLAGS += -lreadline

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
