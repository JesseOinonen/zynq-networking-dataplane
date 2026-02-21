# Compile and elaborate the simulation
open_project ./dataplane.xpr
set_property top top [get_filesets sim_1]

puts "======================================"
puts "Compiling and Elaborating Design"
puts "======================================"
puts "Project: dataplane"
puts "Fileset: sim_1"
puts "Top module: top"
puts "======================================"

# Launch simulation (compile and elaborate, but don't run)
launch_simulation -step compile
launch_simulation -step elaborate

puts "Compilation and elaboration complete."
quit
