# ============================================================================
# Vivado on Windows called from WSL (Windows Subsystem for Linux)
# ============================================================================
# 
# IMPORTANT: This Makefile runs on Linux/WSL but invokes Windows Vivado.
# You MUST update VIVADO_PATH to match your Windows Vivado installation.
#
# To find your Vivado installation on Windows:
#   - Open Windows PowerShell and run: Get-Command vivado.bat
#   - Or check: C:\Xilinx\Vivado\<version>\bin\vivado.bat
#              or: C:\AMDDesignTools\<version>\Vivado\bin\vivado.bat
#
# Then update the path below (use Windows path format with backslashes):
# ============================================================================

VIVADO_PATH := cmd.exe /c "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
VIVADO  := $(VIVADO_PATH)

# Full Windows path to xsim (update if your Vivado is installed elsewhere)
XSIM_WIN := C:\AMDDesignTools\2025.2\Vivado\bin\xsim.bat

# For running xsim from WSL, we need the Windows path
# This assumes your repo is at C:\Users\Jesse\Documents\GitHub\zynq-networking-dataplane
REPO_WIN_PATH := C:\Users\Jesse\Documents\GitHub\zynq-networking-dataplane

PROJECT := dataplane
BUILD   := build/$(PROJECT)
XPR     := $(BUILD)/$(PROJECT).xpr
SIM_DIR := $(BUILD)/$(PROJECT).sim/sim_1/behav/xsim

# Windows simulation directory (use explicit build layout)
# Use the concrete Windows-style build path so cmd.exe can cd to it from WSL
SIM_WIN_PATH := $(REPO_WIN_PATH)\vivado\build\$(PROJECT)\$(PROJECT).sim\sim_1\behav\xsim

TEST ?= axi4_lite
TESTS := axi4_lite axi_rx flow_key_gen flow_table action_stage

.PHONY: all project sim regression gui sim_gui clean help

all: sim

help:
	@echo "Zynq Networking Dataplane - Testbench Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make sim TEST=<testname>      Run a single testcase"
	@echo "  make regression               Run all testcases"
	@echo "  make gui                      Open Vivado GUI with project"
	@echo "  make sim_gui TEST=<testname>  Run test then open GUI"
	@echo "  make clean                    Remove build directory"
	@echo ""
	@echo "Available tests: $(TESTS)"
	@echo "Default test: $(TEST)"

$(BUILD):
	@mkdir -p $(BUILD)

# Create project only if it does not exist
project: $(BUILD)
	@if [ ! -f "$(BUILD)/$(PROJECT).xpr" ]; then \
	    echo "Creating Vivado project..."; \
	    cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/build.tcl; \
	else \
	    echo "Project already exists at $(XPR)"; \
	fi

# Compile and elaborate (needed once, before running tests)
compile: project
	@echo "Compiling and elaborating design..."
	@cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/compile.tcl

# Run single test simulation using existing project
sim: compile
	@echo "================================================"
	@echo "Running test: $(TEST)"
	@echo "================================================"
	@cmd.exe /c "cd /d $(SIM_WIN_PATH) && $(XSIM_WIN) top_behav -R --testplusarg \"TEST=$(TEST)\""
	@echo "Test $(TEST) completed"

# Run regression: compile once, then run each test
regression: compile
	@echo "================================================"
	@echo "Starting REGRESSION - Running all tests"
	@echo "Tests: $(TESTS)"
	@echo "================================================"
	@set -e; \
	failed=0; \
	passed=0; \
	for t in $(TESTS); do \
	  echo ""; \
	  echo ">>> Running test: $$t"; \
	  if cmd.exe /c "cd /d $(SIM_WIN_PATH) && $(XSIM_WIN) top_behav -R --testplusarg \"TEST=$$t\""; then \
	    passed=$$((passed+1)); \
	    echo "PASSED: $$t"; \
	  else \
	    echo "FAILED: $$t"; \
	    failed=$$((failed+1)); \
	  fi; \
	done; \
	echo ""; \
	echo "================================================"; \
	echo "REGRESSION COMPLETE: $$passed passed, $$failed failed"; \
	echo "================================================"; \
	[ $$failed -eq 0 ]

# GUI open
gui: project
	@echo "Opening Vivado GUI..."
	cd $(BUILD) && $(VIVADO) $(PROJECT).xpr &

# Simulation then GUI (debug single test then open project)
sim_gui: project
	@echo "Running $(TEST) then opening GUI..."
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/sim.tcl -tclargs $(TEST)
	cd $(BUILD) && $(VIVADO) $(PROJECT).xpr &

clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD)
