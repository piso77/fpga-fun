include project.cfg

default: $(FW)
	iverilog -DDEBUG -o dsn attopu_tb.v $(VSOURCE)
	vvp dsn
	#gtkwave test_attopu.vcd

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

%.hex: %.asm
	node ../../nanoasm/src/asmmain.js attopu.json $< > $@

clean:
	rm -rf build *.hex ice40_pll.v
