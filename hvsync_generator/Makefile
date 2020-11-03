include project.cfg

ico: $(FW)
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

papi: $(FW)
	$(MAKE) BOARD=papilio -f ./Makefile.xilinx

ico_prog:
	icoprog -p < build/$(PROJECT).bin

papi_prog:
	papilio-prog -vf build/$(PROJECT).bin

%.hex: %.asm
	node ../../nanoasm/src/asmmain.js femto8/femto8.json $< > $@

clean:
	rm -rf build *.hex
