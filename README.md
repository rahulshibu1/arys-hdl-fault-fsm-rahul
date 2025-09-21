Fault Handling FSM in Verilog



Project Overview

This project implements a \*\*Fault Handling Finite State Machine (FSM)\*\* in Verilog HDL.  

The FSM detects and classifies system faults such as:

\- Over-Voltage (OV)

\- Under-Voltage (UV)

\- Over-Temperature (OT)

\- Under-Current (UC)



It transitions through four states:  

\*\*NORMAL → WARNING → FAULT → SHUTDOWN\*\*, based on the persistence of faults.  

Transient glitches are ignored, while persistent faults escalate the system state.



---



Tools Used

\- Icarus Verilog (`iverilog`, `vvp`) – Simulation  

\- GTKWave – Waveform visualization  

\- Python -(pandas, matplotlib) – CSV log analysis \& plotting  

\- GitHub – Version control and documentation  



---



Repository Structure

src/ → Verilog RTL + Testbench

simulations/ → Simulation logs (CSV) + Plots

waveforms/ → GTKWave screenshots

docs/ → Report (PDF)



---



---



How to Run



1\. \*\*Compile FSM + Testbench\*\*

&nbsp;  ```bash

&nbsp;  cd src

&nbsp;  iverilog -o sim\_fault\_fsm fault\_fsm.v tb\_fault\_fsm.v

&nbsp;  vvp sim\_fault\_fsm

2\. Open Waveforms

&nbsp;  gtkwave tb\_fault\_fsm.vcd

3\. Generate python plot

&nbsp;  python plot\_sim.py
  
Results

Transient UC Fault → FSM stays in NORMAL.

Persistent OV Fault → FSM transitions NORMAL → WARNING → FAULT, resets on clear.

Persistent UC Fault → FSM escalates to SHUTDOWN (latched).

Masked UC Fault → Input ignored when mask is enabled.

Key Learnings

Designed persistence counters to filter glitches.

Implemented masking and operator acknowledgment.

Automated plotting from simulation logs using Python.

Maintained clean GitHub commit history.

Author

Rahul S.
B.E. Electronics & Communication Engineering
Ramaiah Institute of Technology
September 2025



