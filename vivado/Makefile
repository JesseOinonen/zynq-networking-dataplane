VIVADO  := cmd.exe /c "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat" # Adjust path as needed for Vivado
PROJECT := dataplane
BUILD   := build/$(PROJECT)

all: sim

$(BUILD):
	mkdir -p $(BUILD)

project: $(BUILD)
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/create_project.tcl

sim: project
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/sim.tcl

gui:
	cd $(BUILD) && $(VIVADO) $(PROJECT).xpr &

sim_gui: project
	cd $(BUILD) && $(VIVADO) -mode batch -source ../../scripts/sim.tcl && $(VIVADO) $(PROJECT).xpr &

clean:
	rm -rf build/$(PROJECT)
