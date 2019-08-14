SRCS=lfsr.v lfsr_tb.v

all:
	iverilog -o dsn $(SRCS)
	vvp dsn
	#gtkwave test.vcd
