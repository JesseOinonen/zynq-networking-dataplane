# Testbench Guide

This document explains how to run simulations for the Zynq Networking Dataplane project.

## Quick Start


### Run a Single Test
```bash
make sim TEST=axi4_lite
```

Available tests:
- `axi4_lite` - AXI4-Lite basic read/write test
- `axi_rx` - AXI RX module test
- `flow_key_gen` - Flow key generation test
- `flow_table` - Flow table test
- `action_stage` - Action stage test

### Run All Tests (Regression)
```bash
make regression
```

This will compile once, then run all tests sequentially and report results.

### Open Vivado GUI
```bash
make gui
```

To run simulations in the GUI:
1. Run `make gui` to open Vivado
2. Select Simulation in the left panel
3. Right-click and select "Run Simulation"
4. In the Tcl console: `run all`

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make sim TEST=<name>` | Compile design, then run a single testcase with xsim |
| `make regression` | Compile design once, then run all testcases with xsim |
| `make gui` | Open Vivado GUI with project (for interactive debugging) |
| `make sim_gui TEST=<name>` | Open Vivado GUI with project |
| `make clean` | Remove build directory |
| `make help` | Display help message |

## Test Infrastructure

### Directory Structure
```
pl/tb/
├── top/
│   ├── top.sv              - Main testbench (dispatches to testcases)
│   ├── axi_if.sv           - AXI interface with read/write/stream tasks
│   ├── submodules.sv       - Clock and reset generators
│   └── register.svh        - Register definitions (CSR addresses)
└── cases/
    ├── axi4_lite_testcase_pkg.sv
    ├── axi_rx_testcase_pkg.sv
    ├── flow_key_gen_testcase_pkg.sv
    ├── flow_table_testcase_pkg.sv
    └── action_stage_testcase_pkg.sv
```

### How Tests Are Invoked

1. **Makefile** invokes Vivado to compile and elaborate (via `compile.tcl`)
2. **compile.tcl** (Vivado Tcl script) compiles the design once and elaborates it
3. This creates the xsim executable and simulation database
4. **Makefile** then calls xsim directly with `+TEST=<name>` plusarg
5. **top.sv** (testbench module) receives the test name via `$value$plusargs("TEST=%s", testname)`
6. **run_test()** task dispatches to the appropriate testcase package
7. **testcase package** runs the test and reports results

This workflow compiles once and runs tests directly with xsim, which is much faster than launching Vivado for each test.

### Adding a New Test

To add a new testcase:

1. Create `pl/tb/cases/my_test_testcase_pkg.sv`:
```systemverilog
package my_test_testcase_pkg;
    `include "../top/register.svh"

    task my_test_testcase(input virtual axi_if axi, output int passed, output int total);
        logic [31:0] read_data;

        $display("Running my_test_testcase...");
        
        // Your test code here
        
        passed++;
        total++;
        $display("Completed my_test_testcase.");
    endtask

endpackage
```

2. Update `pl/tb/top/top.sv`:
```systemverilog
// Add import at top
import my_test_testcase_pkg::*;

// Add dispatch case in run_test() task
else if (name == "my_test") my_test_testcase(tb_axi, passed, total);
```

3. Add test name to Makefile `TESTS` variable:
```makefile
TESTS := axi4_lite axi_rx flow_key_gen flow_table action_stage my_test
```

4. Run with:
```bash
make sim TEST=my_test
```

## Vivado Configuration

The testbench uses:
- **Top module**: `top` (from `pl/tb/top/top.sv`)
- **Simulator**: xsim (Vivado's built-in simulator)
- **Clock**: 50 MHz (10ns period)
- **Reset**: Active low, asserts for first 100ns

### WSL Setup (Windows Subsystem for Linux)

If you're running Linux/WSL but Vivado is installed on Windows:

1. Find your Windows Vivado installation path
2. Update `vivado/Makefile` - change this line:
   ```makefile
   VIVADO_PATH := cmd.exe /c "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
   ```
   to match your actual Vivado version and location.

3. To find the correct path on Windows:
   - Open PowerShell and run: `Get-Command vivado.bat`  
   - Or check: `C:\Xilinx\Vivado\<version>\bin\vivado.bat` or `C:\AMDDesignTools\<version>\Vivado\bin\vivado.bat`

The file will then look like:
```makefile
VIVADO_PATH := cmd.exe /c "C:\Xilinx\Vivado\2025.2\bin\vivado.bat"
```

The Makefile will then properly invoke Windows Vivado from the WSL Linux shell.

## Troubleshooting

### "Vivado command not found" or "vivado.bat not found"
- You're likely missing the correct Windows Vivado path in the Makefile
- Check the "WSL Setup" section above
- Run this in Windows PowerShell to find Vivado: `Get-Command vivado.bat`
- Update the `VIVADO_PATH` line in `vivado/Makefile` with the correct path

### "Project doesn't exist"
- First run will create the project automatically using `scripts/build.tcl`
- This may take a few minutes
- Ensure you have write permissions in `vivado/build/`

### Test fails with "Unknown test"
- Check spelling of test name
- Verify test is imported in `top.sv`
- Verify test name is handled in `run_test()` task

### Regression stops early
- Check simulation output for errors
- Common issues: timeouts in interface tasks, assertion failures
- Use `make sim_gui TEST=failing_test` to debug in GUI

### "Permission denied" errors on `cmd.exe`
- Ensure `cmd.exe` is in your Windows PATH
- Run `which cmd.exe` from WSL to verify
- If not found, your Windows installation may be incomplete

## Output

Each test produces a transcript with:
- Test start/completion messages
- Any error or warning messages
- Final result: "RESULT: X / Y PASSED"

A failed test returns non-zero exit code (causes regression to stop).
