# UVM_Verification_ABP_RAM-
ABP RAM Verification using UVM
This project implements and verifies a simple RAM model using the Advanced Bus Protocol (ABP) in SystemVerilog with the Universal Verification Methodology (UVM) framework.

📁 Project Structure
.
├── rtl/
│   └── abp_ram.sv           # ABP RAM RTL design
├── tb/
│   ├── testbench.sv         # Top-level UVM testbench
│   ├── env.sv               # UVM environment
│   ├── agent.sv             # UVM agent (driver, monitor, sequencer)
│   ├── sequence.sv          # UVM sequences
│   └── scoreboard.sv        # UVM scoreboard
├── sim/
│   └── run.do               # Simulation script (ModelSim/VCS)
└── README.md                # Project documentation
✅ Features
ABP-compliant RAM interface
UVM-based testbench with:
Driver, Monitor, Sequencer
Scoreboard for data checking
Functional coverage (optional)
Read and Write transaction support
Self-checking testbench with UVM reports
🧪 Sample Output  :
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1490000: uvm_test_top.env.a.d [DRV] mode:readd, addr:5, wdata:1481692511, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1530000: uvm_test_top.env.a.m [MON] DATA READ addr:5 data:0 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1530000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:5, rdata:0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1550000: uvm_test_top.env.a.d [DRV] mode:readd, addr:23, wdata:4221967880, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1590000: uvm_test_top.env.a.m [MON] DATA READ addr:23 data:0 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1590000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:23, rdata:0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1610000: uvm_test_top.env.a.d [DRV] mode:readd, addr:0, wdata:371705282, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1650000: uvm_test_top.env.a.m [MON] DATA READ addr:0 data:0 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1650000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:0, rdata:0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1670000: uvm_test_top.env.a.d [DRV] mode:readd, addr:0, wdata:2815806605, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1710000: uvm_test_top.env.a.m [MON] DATA READ addr:0 data:0 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1710000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:0, rdata:0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1730000: uvm_test_top.env.a.d [DRV] mode:readd, addr:22, wdata:2964337257, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1770000: uvm_test_top.env.a.m [MON] DATA READ addr:22 data:0 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1770000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:22, rdata:0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(226) @ 1790000: uvm_test_top.env.a.d [DRV] mode:readd, addr:2, wdata:817297238, rdata:x, slverr:x
# KERNEL: UVM_INFO /home/runner/testbench.sv(295) @ 1830000: uvm_test_top.env.a.m [MON] DATA READ addr:2 data:4292240545 slverr:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(362) @ 1830000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:2, rdata:4292240545
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 1830000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 1830000: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :   96
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [DRV]    31
# KERNEL: [MON]    31
# KERNEL: [RNTST]     1
# KERNEL: [SCO]    31
# KERNEL: [TEST_DONE]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
# KERNEL: Time: 1830 ns,  Iteration: 63,  Instance: /tb,  Process: @INITIAL#484_2@.
# KERNEL: stopped at time: 1830 ns
# VSIM: Simulation has finished. There are no more test vectors to simulate.
# VSIM: Simulation has finished.
Done
