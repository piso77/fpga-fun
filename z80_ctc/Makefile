GHDL=ghdl
GHDLFLAGS=
MODULES=ctc_counter ctc_top ctc_tb


test: $(MODULES)
	$(GHDL) -r ctc_tb --vcd=ctc_tb.vcd
	#./full_adder_testbench --vcd=full_adder_testbench.vcd

%: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
	$(GHDL) -e $(GHDLFLAGS) $@

clean:
	echo "Cleaning up..."
	rm -f *.o *_testbench work*.cf e*.lst *.vcd
