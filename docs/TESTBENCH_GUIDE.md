# Testbench Guide

This document describes the UVM testbench architecture and simulation workflow for the Zynq Networking Dataplane project.

## Quick Start

### Run a Single Test
```bash
make sim TEST=flow_table_test
```

Default test (if `TEST` is omitted): `axi4_lite_test`

### Run All Tests (Regression)
```bash
make regression
```

### Open Vivado GUI
```bash
make gui
```

---

## Available Tests

| Test name | Description |
|---|---|
| `axi4_lite_test` | Basic AXI4-Lite register write/read verification |
| `parser_test` | Sends a TCP/IP packet and checks parsed header fields |
| `flow_key_gen_test` | Sends a packet and verifies extracted 128-bit flow key |
| `flow_table_test` | Writes a flow table entry, then sends a matching packet |
| `action_stage_test` | Exercises the action stage control register |

---

## Makefile Targets

| Target | Description |
|---|---|
| `make sim TEST=<name>` | Build project and run a single test with xsim |
| `make regression` | Build project once, then run all tests sequentially |
| `make files` | Re-add/update source files in an existing project |
| `make gui` | Open Vivado GUI with the project |
| `make clean` | Remove the entire build directory |

---

## UVM Architecture

### Directory Structure

```
pl/tb/
├── top/
│   ├── axi_if.sv          - AXI4-Lite + AXI Stream interface (tasks: write, read, stream_send)
│   ├── submodules.sv      - Clock (50 MHz) and reset generators
│   ├── top.sv             - Testbench top: instantiates DUT and interface, calls run_test()
│   └── register.svh       - CSR address defines
├── uvm/
│   ├── dp_pkg.sv          - Top-level UVM package (`include`s everything below)
│   ├── axi_lite_seq_item.sv
│   ├── axi_lite_driver.sv
│   ├── axi_lite_monitor.sv
│   ├── axi_lite_scoreboard.sv
│   ├── axi_lite_agent.sv
│   ├── axi_lite_seq.sv    - axi_lite_write_seq, axi_lite_read_seq
│   ├── axi_stream_seq_item.sv
│   ├── axi_stream_driver.sv
│   ├── axi_stream_monitor.sv
│   ├── axi_stream_agent.sv
│   ├── parser_seq.sv      - Sends the reference TCP/IP packet over AXI Stream
│   ├── dp_vseq_base.sv    - Virtual sequence base (holds axi_lite_seqr + axi_stream_seqr handles)
│   ├── dp_env.sv          - UVM env: contains axi_lite_agent + axi_stream_agent
│   └── dp_test_base.sv    - UVM test base: gets vif from config_db, builds env
└── cases/
    ├── axi4_lite_test.sv  - axi4_lite_vseq + axi4_lite_test
    ├── parser_test.sv     - parser_vseq + parser_test
    ├── flow_key_gen_test.sv
    ├── flow_table_test.sv
    └── action_stage_test.sv
```

### Component Hierarchy

```
top (module)
└── uvm_test_top  [+UVM_TESTNAME=<test_class>]
    └── dp_test_base / <test_class>
        └── dp_env
            ├── axi_lite_agent
            │   ├── uvm_sequencer #(axi_lite_seq_item)   ← axi_lite_seqr
            │   ├── axi_lite_driver    (calls axi_vif.write / axi_vif.read)
            │   └── axi_lite_monitor
            └── axi_stream_agent
                ├── uvm_sequencer #(axi_stream_seq_item) ← axi_stream_seqr
                ├── axi_stream_driver  (calls axi_vif.stream_send)
                └── axi_stream_monitor
```

### Virtual Interface Flow

`top.sv` puts `tb_axi` into the config DB:
```systemverilog
uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top", "axi_vif", tb_axi);
```

`dp_test_base` retrieves it and distributes it to both agents:
```systemverilog
uvm_config_db#(virtual axi_if)::set(this, "env.axi_agent.*",    "axi_vif", axi_vif);
uvm_config_db#(virtual axi_if)::set(this, "env.stream_agent.*", "axi_vif", axi_vif);
```

### Test Execution Flow

1. `xsim` is launched with `+UVM_TESTNAME=<classname>`
2. UVM's `run_test()` in `top.sv` instantiates the named test class
3. The test creates a virtual sequence (`*_vseq extends dp_vseq_base`)
4. The vseq sets sequencer handles and calls `vseq.start(null)`
5. Inside the vseq `body()`, stimulus is driven through sequences:
   - `axi_lite_write_seq` / `axi_lite_read_seq` → `axi_lite_seqr` → driver → `axi_vif.write/read`
   - `parser_seq` → `axi_stream_seqr` → driver → `axi_vif.stream_send`

---

## Adding a New Test

### 1. Create the test file in `pl/tb/cases/`

```systemverilog
// pl/tb/cases/my_test.sv

class my_vseq extends dp_vseq_base;
    `uvm_object_utils(my_vseq)

    function new(string name = "my_vseq");
        super.new(name);
    endfunction

    task body();
        axi_lite_write_seq wr;
        axi_lite_read_seq  rd;

        wr = axi_lite_write_seq::type_id::create("wr");
        wr.addr = `DP_CTRL;
        wr.data = 32'hDEADBEEF;
        wr.start(axi_lite_seqr);

        rd = axi_lite_read_seq::type_id::create("rd");
        rd.addr = `DP_CTRL;
        rd.start(axi_lite_seqr);

        if (rd.data !== 32'hDEADBEEF)
            `uvm_error("MY_TEST", $sformatf("Mismatch: got 0x%08X", rd.data))
        else
            `uvm_info("MY_TEST", "PASSED", UVM_LOW)
    endtask
endclass

class my_test extends dp_test_base;
    `uvm_component_utils(my_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        my_vseq vseq = my_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask
endclass
```

### 2. Add the `\`include` to `dp_pkg.sv`

```systemverilog
`include "my_test.sv"
```

### 3. Add to the `TESTS` list in the Makefile

```makefile
TESTS := axi4_lite_test parser_test flow_key_gen_test flow_table_test action_stage_test my_test
```

### 4. Run it

```bash
make sim TEST=my_test
```

---

## Simulation Sources in Vivado

Only the following files are added as Vivado simulation sources. Everything else is
`\`include`d by `dp_pkg.sv` via the configured include directories.

| File(s) | Why added directly |
|---|---|
| `pl/tb/top/*.sv` | Independent modules: `axi_if`, `submodules`, `top` |
| `pl/tb/uvm/dp_pkg.sv` | UVM package entry point |

Include directories set in `compile.tcl` and `add_files.tcl` (absolute paths):
- `pl/tb/uvm/`
- `pl/tb/cases/`
- `pl/tb/top/`

---

## Vivado Configuration

| Setting | Value |
|---|---|
| Top module (sim) | `top` |
| Simulator | xsim (Vivado built-in) |
| UVM library | `-L uvm` (xvlog + xelab) |
| Clock | 50 MHz (10 ns half-period) |
| Reset | Active-low, asserts for first 100 ns |

---

## Troubleshooting

### `cannot open include file '*.sv'`
Run `make files` to update include directory settings in the project, then `make clean && make sim`.

### `use of undefined macro 'uvm_error'` in `axi_if.sv`
`axi_if.sv` is compiled before `dp_pkg.sv` and has no access to UVM macros.
Use `$error(...)` instead of `` `uvm_error `` inside the interface.

### `cd: can't cd to vivado/build/.../xsim`
The regression loop uses an absolute `$(SIM_DIR_ABS)` path — if you see this error, ensure
you are running `make` from the repository root.

### Test not found / UVM fatal `UVM_TESTNAME`
- The `TEST` variable must match the exact UVM class name (e.g. `flow_table_test`, not `flow_table`)
- Verify the class has `` `uvm_component_utils(<classname>) `` registered
- Verify `` `include "<file>.sv" `` is present in `dp_pkg.sv`

### Simulation hangs (timeout)
AXI handshake tasks in `axi_if.sv` have a 500 ns timeout. A hang typically means
the DUT is not asserting `AWREADY`/`WREADY`/`ARREADY`/`RVALID`/`tready`.
Check the DUT's clock and reset connectivity in `top.sv`.
