# Adds/upserts design and testbench sources into the currently open Vivado project.
# Can be run repeatedly; Vivado will ignore already-added files.

# RTL sources
add_files [glob ../../../pl/rtl/axi/*.sv]
add_files [glob ../../../pl/rtl/parser/*.sv]
add_files [glob ../../../pl/rtl/top/*.sv]
add_files [glob ../../../pl/rtl/match_action/*.sv]
# add_files [glob ../../../pl/rtl/observability/*.sv]

# Testbench files
# top/*.sv = interface, clock/reset generators, testbench top (independent modules)
add_files -fileset sim_1 [glob ../../../pl/tb/top/*.sv]
# dp_pkg.sv is the only UVM compilation unit — it `include`s everything under
# uvm/ and cases/ so those files must NOT be added separately
add_files -fileset sim_1 ../../../pl/tb/uvm/dp_pkg.sv

# Constraints
add_files -fileset constrs_1 ../../../flow/constraints.xdc

# Include directories for `include resolution in dp_pkg.sv (absolute paths)
set tb_dir [file normalize [file join [get_property DIRECTORY [current_project]] ../../../pl/tb]]
set_property include_dirs [list \
    [file join $tb_dir uvm] \
    [file join $tb_dir cases] \
    [file join $tb_dir top] \
] [get_filesets sim_1]

# Ensure top modules are set
set_property top dataplane_top [current_fileset]; # Synthesis top
set_property top top [get_fileset sim_1];         # Simulation top

puts "Vivado project file list updated (add_files.tcl)"
