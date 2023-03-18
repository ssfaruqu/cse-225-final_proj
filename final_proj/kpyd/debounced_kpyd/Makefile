TOP_MODULE = debounced_kpyd
SYNTH_SOURCES += $(TOP_MODULE).sv
SYNTH_SOURCES += ../edge_state_machine/edge_state_machine.sv
SYNTH_SOURCES += ../debouncer/debouncer.sv
SYNTH_SOURCES += ../sync/sync.sv
SYNTH_SOURCES += ../../provided_modules/inv.sv
SYNTH_SOURCES += ../../provided_modules/dff.sv
NONSYNTH_SOURCES += ../../provided_modules/nonsynth_clock_gen.sv
NONSYNTH_SOURCES += ../../provided_modules/nonsynth_reset_gen.sv
-include ../../simulation.mk
-include ../../fpga.mk
