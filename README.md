# FPGA Labs — CSE 100 (Logic Design)

Verilog labs for CSE 100 / CSE 100L, a digital logic design course at UC Santa Cruz.
All designs target the **Digilent Basys 3** board (Xilinx Artix-7 `xc7a35t`) and were
built and simulated in **Xilinx Vivado**.

Each lab folder contains the Verilog source, its `Basys3_Master.xdc` pin constraints,
and any testbench. Shared utility modules (seven-segment decoders, clock dividers,
ring counters, etc.) are duplicated into the labs that use them so each lab builds on
its own.

## Labs

| Lab | Topic | Highlights |
|-----|-------|------------|
| **Lab 1** | Octal → 7-segment display | `oct2ssd` — combinational decoder driving the on-board display |
| **Lab 2** | Binary arithmetic | 8-bit ripple-carry adder (`adder8`), add/subtract unit (`AddSub8`), sign changer, with a testbench |
| **Lab 3** | Counters & sequential logic | Up/down loadable counters (`countUD8L`/`countUD16L`), ring counter, edge detector, `testTC` bench |
| **Lab 4** | FSM + LFSR | Finite state machine (`fsm`), 8-bit LFSR, LED shifter and timed counters, with simulation benches |
| **Lab 5** | FSM / LFSR (refined) | Expanded state machine and top-level integration |
| **Lab 6** | VGA "Newton Game" | A playable catch-the-falling-apples game rendered over VGA — Mealy game FSM, pixel renderer, sync generator, player controller |

## Toolchain

- **HDL:** Verilog
- **Board:** Digilent Basys 3 (Xilinx Artix-7 `xc7a35t-1cpg236c`)
- **Tools:** Xilinx Vivado (synthesis, simulation, bitstream generation)

## Building a lab

1. Create a new Vivado RTL project targeting `xc7a35t-1cpg236c`.
2. Add the `.v` sources and the `Basys3_Master.xdc` from the lab folder.
3. Set the lab's top module as the top (e.g. `topmod` for Lab 6, `top` for Lab 4).
4. Run synthesis → implementation → generate bitstream, then program the board.

---

*Coursework from CSE 100/L at UC Santa Cruz.*
