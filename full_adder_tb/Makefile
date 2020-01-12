#include project.cfg

GHDL=ghdl
GHDLFLAGS=
MODULES=full_adder full_adder_testbench


test: $(MODULES)
	$(GHDL) -r full_adder_testbench --vcd=full_adder_testbench.vcd
	#./full_adder_testbench --vcd=full_adder_testbench.vcd

%: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
	$(GHDL) -e $(GHDLFLAGS) $@

clean:
	echo "Cleaning up..."
	rm -f *.o *_testbench work*.cf e*.lst *.vcd
