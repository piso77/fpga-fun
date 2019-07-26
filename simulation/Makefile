SRCS = test.v test_tb.v
SRCS8 = prsgen8_tb.v prsgen8.v

.PHONY: pre pre8 post

# presynthesys
pre: $(SRCS)
	iverilog -o test_pre $(SRCS)
	./test_pre

pre8: $(SRCS8)
	iverilog -o prsgen8_tb $(SRCS8)
	./prsgen8_tb

# postsynthesis
post: $(SRCS)
	# first run synthesis
	yosys -p 'synth_ice40 -top test -blif test.blif' test.v
	# convert the BLIF netlist to a verilog netlist Icarus Verilog understand
	yosys -o test_syn.v test.blif
	# build the simulation binary from the test bench, the synthesized design, and the iCE40 simulation models
	iverilog -o test_post -D POST_SYNTHESIS test_tb.v test_syn.v \
		`yosys-config --datdir/ice40/cells_sim.v`
	# and run it
	./test_post
