# Adds/upserts design and testbench sources into the currently open Vivado project.
# Can be run repeatedly; Vivado will ignore already-added files.

# RTL sources
add_files [glob ../../../pl/rtl/dataplane_pkg.sv]
add_files [glob ../../../pl/rtl/axi/*.sv]
add_files [glob ../../../pl/rtl/parser/*.sv]
add_files [glob ../../../pl/rtl/csr.sv]
add_files [glob ../../../pl/rtl/top/dataplane_top.sv]
add_files [glob ../../../pl/rtl/match_action/*.sv]
# add_files [glob ../../../pl/rtl/observability/*.sv]
# add_files [glob ../../../pl/rtl/*.sv]

# Testbench files
add_files -fileset sim_1 [glob ../../../pl/tb/cases/*.sv]
add_files -fileset sim_1 [glob ../../../pl/tb/top/*.sv]

# Constraints
add_files -fileset constrs_1 ../../constraints.xdc

# Ensure top modules are set
set_property top dataplane_top [current_fileset]; # Synthesis top
set_property top top [get_fileset sim_1];         # Simulation top

puts "Vivado project file list updated (add_files.tcl)"
