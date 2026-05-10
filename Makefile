VIVADO ?= /opt/2025.2/Vivado/bin/vivado
XSIM := $(dir $(VIVADO))xsim

PROJECT := dataplane
BUILD := vivado/build/$(PROJECT)
XPR := $(BUILD)/$(PROJECT).xpr
SIM_DIR     := $(BUILD)/$(PROJECT).sim/sim_1/behav/xsim
SIM_DIR_ABS := $(abspath $(SIM_DIR))
SCRIPTS_DIR := ../../../flow/scripts

TEST ?= axi4_lite_test
TESTS := axi4_lite_test parser_test flow_key_gen_test flow_table_test action_stage_test

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
	@cd $(SIM_DIR) && $(XSIM) top_behav -R --testplusarg "UVM_TESTNAME=$(TEST)"
	@echo "Test $(TEST) completed"

# Run regression: build once, then run each test
regression: build
	@echo "================================================"
	@echo "Starting REGRESSION - Running all tests"
	@echo "Tests: $(TESTS)"
	@echo "================================================"
	@if [ ! -d "$(SIM_DIR)" ]; then \
	  echo "Simulation build not found, compiling..."; \
	  cd $(BUILD) && $(VIVADO) -mode batch -source $(SCRIPTS_DIR)/compile.tcl; \
	fi
	@failed=0; \
	passed=0; \
	failed_tests=""; \
	for t in $(TESTS); do \
	  echo ""; \
	  echo ">>> Running test: $$t"; \
	  _log="/tmp/dp_regress_$$t.log"; \
	  cd $(SIM_DIR_ABS) && $(XSIM) top_behav -R --testplusarg "UVM_TESTNAME=$$t" 2>&1 | tee "$$_log"; \
	  if grep -q "TEST PASSED" "$$_log"; then \
	    passed=$$((passed+1)); \
	    echo "PASSED: $$t"; \
	  else \
	    failed=$$((failed+1)); \
	    failed_tests="$$failed_tests $$t"; \
	    echo "FAILED: $$t"; \
	  fi; \
	  rm -f "$$_log"; \
	done; \
	echo ""; \
	echo "================================================"; \
	echo "REGRESSION COMPLETE: $$passed passed, $$failed failed"; \
	if [ $$failed -gt 0 ]; then \
	  echo "Failed tests:"; \
	  for ft in $$failed_tests; do \
	    echo "  - $$ft"; \
	  done; \
	fi; \
	echo "================================================"; \
	[ $$failed -eq 0 ]

# Open Vivado GUI with test configured
gui: build
	@echo "Opening Vivado GUI for test: $(TEST)"
	cd $(BUILD) && $(VIVADO) -mode gui -source $(SCRIPTS_DIR)/sim.tcl -tclargs $(TEST) &

clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD)
