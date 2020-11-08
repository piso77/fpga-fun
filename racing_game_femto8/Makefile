include project.cfg

ico: $(FW)
	icepll -i 100 -o $(PIXCLK) -mf ice40_pll.v
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
	node ../../nanoasm/src/asmmain.js femto8/femto8.json $< > $@

clean:
	rm -rf build *.hex ice40_pll.v
