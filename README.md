# Seeum Faruque cse-x25-final_proj Repository

## Getting Started

1. Install these tools in order to run program:
- *Icarus Verilog*: https://bleyer.org/icarus/ (v10.0)
- *Verilator*: https://verilator.org/guide/latest/index.html (v5.0)
- *GTKWave*: https://gtkwave.sourceforge.net/ (v3.0)
- *Yosys*: https://yosyshq.net/yosys/ (v0.23)
- *nextpnr-ice40*: https://github.com/YosysHQ/nextpnr (v0.4)
- *project-icestorm*: https://clifford.at/icestorm (No Version)

Follow these instructions to install the OSS-CAD-Suite, which contains
all the tools: https://github.com/YosysHQ/oss-cad-suite-build#installation

2. Clone the repository into any location of your choosing on your PC
Instructions on cloning repositories: https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository

3. To build the program onto your FPGA, enter into the finsl_proj/top/top directory on your CMD and enter the command 
"make prog" into your terminal. After the progam finishes loading, the soundboard functionality will be implemented
on your FPGA

4. Plug in an AXI i2s2 sound module into the PMOD1A port, and a Diligent keypad module into the PMOD1B port. You will only need to plug
in headphones/speakers into the green LINE OUT port of the sound module, as sound files are the source of audio.

## Testing

To perform any tests, enter any directory that contains a testbench.sv file and ehter the command "make test".
This will run the testbench on its respective module, generating a verlator.log and iverilator.log file. These
files contain the results of the test in both the Verilator and Icarus Verilog environments. It will also generate
verilator.fst and iverilog.vcd, the waveform files of the test in each respective environment.

Additionally, Makefiles have been provided to directories that don't have testbecnhes to allow cloners to write
their own testbenches if they so desire.

NOTE: The only exception to this is the testbench.sv file in final_proj/load/file_write, it's sole purpose is to
instatiate and run the file_write module to generate random sound files (you still run it with "make test")

## How To Use

There are 3 sections to this soundboard:

1. Sound Keys
To play sounds, press either the A, B, 3, or 6 key. Only sound will play at a time (if you press another key while a 
sound is playing, the old sound will stop and the new one will play), and will play continuouslly. To stop a sound, press
it's desginated key again.

2. Mute
To mute all sounds from playing, press C. To unmute, press C again.

3. Volume
To raise volume, press D (can raise it multiple times). To lowwer volume, press E (can lower it multiple times). There is
a set cap to how volume can be raised or lowered

Loading in sound files:

This program takes in .hex sound files. They should contain raw audio data in the format  of every line containing 24 bits 
written in hexidecimal.

EX:

abc123

2ef35b

...

Files should be named test_<key_you_want_to_assign_file_to>.hex. Then move it to final_prog/load, where it will overwrite the
existing sound file.

Next, go into load.sv and alter the file count values stored in depth_A, depth_B, depth_3, or depth_6 (whichever key you're
loading into) to match the length of your new file. DO NOT INCLUDE THE LAST EMPTY LINE IN YOUR FILE LINE COUNT.

NOTE: The load modle testbench only works with the original sound files. Loading in new files will cause the test to fail

## Implementation Details
At the beginning, load.sv loads in the test_*.sv files into memory

The top module takes as input the signals from the sound and keypad modules. The row and col signals from the keypad are fed into
debounced_kpyd.sv, which outputs a valid signal (set high through edge detection) and what symbol was pressed. When a certain symbol
is pressed and is valid, that flips a signal for an input of load.sv. It then outputs the contents of the designated file loaded into the
pressed key, cycling through it until the input is set low again. This output is then sent to volume.sv, which right-shifts the incoming audio
data by a certain amount (determined by volume keys), and reutrns the result as another output. This final ouput is processed through a FIFO,
feeding the final sound output into the sound module. The mute button controls the valid_i and yumi_i signals of the FIFO, halting the process
if pressed once, and letting the flow continue once pressed again.

## Repository Structure


The repository has the following file structure:

```bash
| README.md (This File)
| LICENSE
├── final_proj
│   ├── fpga.mk
|   ├── simulation.mk
│   ├── kpyd
│   │   ├── debounced_kpyd
│   │   │   ├── debounced_kpyd.sv # Sends kpyd signals to top module
│   │   │   └── Makefile # Makefile provided for cloner use
│   │   ├── debouncer
│   │   │   ├── debouncer.sv # Debounces pressed buttons of kpyd
│   │   │   ├── testbench.sv # Testbench for module
│   │   │   └── Makefile # Makefile for running tests
│   │   ├── edge_state_machine
│   │   │   ├── edge_state_machine.sv # Used for edge detection
│   │   │   ├── testbench.sv # Testbench for module
│   │   │   └── Makefile # Makefile for running tests
│   │   └── sync
│   │       ├── sync.sv # Synchronizer for kpyd row signals
│   │       └── Makefile # Makefile provided for cloner use
│   ├── load
│   │   ├── file_write
│   │   │   ├── file_write.sv # Generates random sound file
│   │   │   ├── testbench.sv # Not actually a testbench, used to compile and run module
│   │   │   └── Makefile # Makefile for testbench.sv
│   │   ├── load.sv # Loads test_*.sv files into memory
│   │   ├── test_*.sv # Sound files that are assigned to corresponding key in their name
│   │   ├── testbench.sv # Testbench for module
│   │   └── Makefile # Makefile for running tests
│   ├── provided_modules
│   │   └──  *.sv # pre-written SystemVerilog files
│   ├── top
│   │   ├── fifo_1r1w
│   │   │   ├── fifo_1r1w.sv # Used to process sound data
│   │   │   ├── testbench.sv # Testbench for module
│   │   │   └── Makefile # Makefile for running tests
│   │   ├── ram_1r1w_sync # Memory for FIFO
│   │   │   ├── ram_1r1w_sync.sv
│   │   │   ├── testbench.sv # Testbench for module
│   │   │   └── Makefile # Makefile for running tests
│   │   └── top
│   │       ├── top.sv # Top-level module that programs FPGA
│   │       └── Makefile # Makefile for programming FPGA
│   └── volume
│       ├── volume.sv # Alters sound data to increase or decrease volume
│       ├── testbench.sv # Testbench for module
│       └── Makefile # Makefile for running tests

```
