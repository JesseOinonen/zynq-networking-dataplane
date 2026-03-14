VIVADO ?= /opt/2025.2/Vivado/bin/vivado
XSIM := $(dir $(VIVADO))xsim

PROJECT := dataplane
BUILD := vivado/build/$(PROJECT)
XPR := $(BUILD)/$(PROJECT).xpr
SIM_DIR := $(BUILD)/$(PROJECT).sim/sim_1/behav/xsim
SCRIPTS_DIR := ../../scripts

TEST ?= axi4_lite
TESTS := axi4_lite axi_rx flow_key_gen flow_table action_stage

.PHONY: all build sim regression gui clean

all: build

# Build dir
$(BUILD):
	@mkdir -p $(BUILD)

# Build (create project + update file list)
build: $(BUILD)
	@cd $(BUILD) && $(VIVADO) -mode batch -source $(SCRIPTS_DIR)/build.tcl

# Update Vivado project file list (use after adding/removing sources)
files: $(BUILD)
	@cd $(BUILD) && $(VIVADO) -mode batch -source $(SCRIPTS_DIR)/add_files.tcl

# Run single test simulation using existing project
sim: build
	@echo "================================================"
	@echo "Running test: $(TEST)"
	@echo "================================================"
	@# Ensure simulation build exists
	@if [ ! -d "$(SIM_DIR)" ]; then \
	  echo "Simulation build not found, compiling..."; \
	  cd $(BUILD) && $(VIVADO) -mode batch -source $(SCRIPTS_DIR)/compile.tcl; \
	fi
	@cd $(SIM_DIR) && $(XSIM) top_behav -R --testplusarg "TEST=$(TEST)"
	@echo "Test $(TEST) completed"

# Run regression: build once, then run each test
regression: build
	@echo "================================================"
	@echo "Starting REGRESSION - Running all tests"
	@echo "Tests: $(TESTS)"
	@echo "================================================"
	@# Ensure simulation build exists
	@if [ ! -d "$(SIM_DIR)" ]; then \
	  echo "Simulation build not found, compiling..."; \
	  cd $(BUILD) && $(VIVADO) -mode batch -source $(SCRIPTS_DIR)/compile.tcl; \
	fi
	@set -e; \
	failed=0; \
	passed=0; \
	for t in $(TESTS); do \
	  echo ""; \
	  echo ">>> Running test: $$t"; \
	  if cd $(SIM_DIR) && $(XSIM) top_behav -R --testplusarg "TEST=$$t"; then \
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

# Open Vivado GUI
gui: build
	@echo "Opening Vivado GUI..."
	cd $(BUILD) && $(VIVADO) $(PROJECT).xpr &

clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD)
