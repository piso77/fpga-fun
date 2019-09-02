default:
	$(error BOARD not defined)

papi: fib8.hex
	$(MAKE) BOARD=papilio -f ./Makefile.xilinx

ico: fib8.hex
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

%8.hex: %8.asm
	node ../../nanoasm/src/asmmain.js femto8.json $< > $@

clean:
	rm -rf build
