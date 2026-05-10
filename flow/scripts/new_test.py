#!/usr/bin/env python3
import sys
import os
import re

if len(sys.argv) != 2:
    print("Usage: new_test.py <testname>")
    sys.exit(1)

name = sys.argv[1]
NAME = name.upper()
out  = f"pl/tb/cases/{name}_test.sv"

if os.path.exists(out):
    print(f"Error: {out} already exists")
    sys.exit(1)

# --- Create test file ---
template = f"""\
class {name}_vseq extends dp_vseq_base;

    `uvm_object_utils({name}_vseq)

    function new(string name = "{name}_vseq");
        super.new(name);
    endfunction

    task body();
        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10us;

        `uvm_info("{NAME}_TEST", "{name}_testcase completed", UVM_LOW)
    endtask

endclass

class {name}_test extends dp_test_base;
    `uvm_component_utils({name}_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        {name}_vseq vseq = {name}_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask

endclass
"""

with open(out, "w") as f:
    f.write(template)
print(f"  Created {out}")

# --- Update Makefile TESTS line ---
makefile = "Makefile"
with open(makefile, "r") as f:
    content = f.read()

content = re.sub(
    r"^(TESTS\s*:=.+)$",
    lambda m: m.group(0) + f" {name}_test",
    content,
    flags=re.MULTILINE
)

with open(makefile, "w") as f:
    f.write(content)
print(f"  Updated {makefile} TESTS")

# --- Update dp_pkg.sv ---
pkg = "pl/tb/uvm/dp_pkg.sv"
with open(pkg, "r") as f:
    content = f.read()

content = content.replace(
    "endpackage",
    f'    `include "{name}_test.sv"\nendpackage'
)

with open(pkg, "w") as f:
    f.write(content)
print(f"  Updated {pkg}")
