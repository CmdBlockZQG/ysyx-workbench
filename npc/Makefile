all:
	@echo "Write this Makefile by your self."

sim_%:
	$(call git_commit, "sim RTL")
	verilator -cc -exe --trace --build -j 0 -Wall csrc/$*.cpp vsrc/$*.v
	obj_dir/V$*

include ../Makefile
