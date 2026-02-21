open_project ./dataplane.xpr
set_property top top [get_filesets sim_1]

puts "======================================"
puts "Launching Vivado Simulation GUI"
puts "======================================"
puts "You can use this for interactive debugging"
puts "======================================"

# For automated testing, use: make sim TEST=<testname>
# For GUI debugging, use: vivado <project.xpr>
# Then in Vivado: Project Manager > Simulation > Run Simulation

launch_simulation

