TOPNAME = top
NXDC_FILES = constr/top.nxdc
INC_PATH = $(abspath ./csrc/include)

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
					-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

$(shell mkdir -p $(BUILD_DIR))

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I , $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -Wall -Werror -DTOP_NAME="\"V$(TOPNAME)\"" 

# rules for llvm disasm
CXXFLAGS += $(shell llvm-config --cxxflags) -fPIE
LDFLAGS += $(shell llvm-config --libs)

LDFLAGS += -lreadline

# @rm -rf $(OBJ_DIR)
$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		-y "$(abspath ./vsrc)" \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

default: $(BIN)

all: default

clean:
	rm -rf $(BUILD_DIR)


ARGS ?= --log=$(BUILD_DIR)/log.txt
override ARGS += --wave=$(BUILD_DIR)/wave.vcd
IMG ?=
ifdef ELF
override ARGS += --elf=$(ELF)
endif

sim: $(BIN)
	$(call git_commit, "sim RTL")
	$(BIN) $(ARGS) $(IMG)

run: $(BIN)
	$(call git_commit, "sim RTL")
	$(BIN) $(ARGS) $(IMG)

run_nt: $(BIN)
	$(BIN) $(ARGS) $(IMG)

.PHONY: default all clean sim run run_nt

include ../Makefile
