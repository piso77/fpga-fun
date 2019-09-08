default: fib8.hex
	iverilog -DDEBUG -o dsn cpu8_tb.v cpu8.v
	vvp dsn
	#gtkwave test_cpu8.vcd

papi: fib8.hex
	$(MAKE) BOARD=papilio -f ./Makefile.xilinx

ico: fib8.hex
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

%8.hex: %8.asm
	node ../../nanoasm/src/asmmain.js femto8.json $< > $@

clean:
	rm -rf build *.hex
