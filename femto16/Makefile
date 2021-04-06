default: fib16.hex
	iverilog -DDEBUG -o dsn cpu16.v cpu16_tb.v
	vvp dsn
	#gtkwave test_cpu8.vcd

papi: fib16.hex
	$(MAKE) BOARD=papilio -f ./Makefile.xilinx

ico: fib16.hex
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

%16.hex: %16.asm
	node ../../nanoasm/src/asmmain.js femto16.json $< > $@

clean:
	rm -rf build *.hex
