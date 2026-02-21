set tests {axi4_lite axi_rx flow_key_gen flow_table action_stage}

set failed 0
foreach t $tests {
  puts "=== Running TEST=$t ==="
  # xsim: anna plusarg ja aja
  if {[catch {exec xsim top -R -testplusarg TEST=$t} msg]} {
    puts "FAILED: $t"
    puts $msg
    set failed 1
  } else {
    puts "PASSED: $t"
  }
}

if {$failed} {
  puts "REGRESSION FAILED"
  exit 1
} else {
  puts "REGRESSION PASSED"
  exit 0
}
