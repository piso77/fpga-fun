include project.cfg

default: $(FW)
	#iverilog -DDEBUG -DFIBOASSERT -o dsn toycpu_tb.v $(VSOURCE)
	#vvp dsn
	iverilog -DDEBUG -o dsn toycpu_tb.v $(VSOURCE)
	vvp dsn
	#gtkwave test_toycpu.vcd

lint:
	verilator --lint-only -Wall $(VSOURCE)

ico: $(FW)
ifdef $(PLL)
	icepll -i 100 -o $(PLL) -mf ice40_pll.v
endif
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

papid: $(FW)
	$(MAKE) CHIP=spartan6 BOARD=papiduo -f ./Makefile.xilinx

papip: $(FW)
	$(MAKE) CHIP=spartan6 BOARD=papipro -f ./Makefile.xilinx

ico_prog:
	icoprog -p < build/$(PROJECT).bin

papi_prog:
	papilio-prog -vf build/$(PROJECT).bit

%.hex: %.asm toycpu.json
	node ../../nanoasm/src/asmmain.js toycpu.json $< > $@

clean:
	rm -rf build *.hex ice40_pll.v
