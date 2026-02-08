set SCRIPT_DIR [file dirname [info script]]

source $SCRIPT_DIR/create_project.tcl
# source $SCRIPT_DIR/create_bd.tcl       UNFINISHED !!!
# validate_bd_design
# save_bd_design
# make_wrapper -files [get_files system.bd] -top
# add_files -norecurse system_wrapper.v