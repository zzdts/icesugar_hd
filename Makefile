# PROJ = example
# PROJ = rs232demo
# PROJ = checker
PROJ = pll_uart_mirror

PIN_DEF = ../../io.pcf
DEVICE = up5k
# DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top top -blif $@' $<

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst up,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'
	# yosys -o $@  $^

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ -D POST_SYNTHESIS $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

sim: $(PROJ)_tb.vcd

postsim: $(PROJ)_syntb.vcd
	open $(PROJ)_syntb.vcd

prog: $(PROJ).bin
	# iceprog $<
	icesprog  $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin
	rm -f $(PROJ)_syntb.lxt  $(PROJ)_syntb.vcd $(PROJ)_syn.v $(PROJ)_syntb

.SECONDARY:
.PHONY: all prog clean
