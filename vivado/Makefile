VIVADO := cmd.exe /c "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
PROJECT := dataplane
BUILD   := build/$(PROJECT)
XPR     := $(BUILD)/$(PROJECT).xpr

all: sim

$(BUILD):
	mkdir $(BUILD)

# Create project only if it does not exist
project: $(BUILD)
	if [ ! -f "$(BUILD)/$(PROJECT).xpr" ]; then \
	    cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/create_project.tcl ; \
	fi

# Run simulation using existing project
sim: project
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/sim.tcl

# GUI open
gui:
	if exist "$(XPR)" ( \
	    cd $(BUILD) && $(VIVADO) $(PROJECT).xpr & \
	) else (echo "Project does not exist. Run 'make project' first.")

# Simulation then GUI
sim_gui: project
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/sim.tcl && $(VIVADO) $(PROJECT).xpr &

clean:
	rm -rf build/$(PROJECT)
