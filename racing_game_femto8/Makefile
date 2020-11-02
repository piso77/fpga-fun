FW=racing8.hex

default:
	$(error BOARD not defined)

ico: $(FW)
	$(MAKE) BOARD=icoboard -f ./Makefile.icestorm

papi: $(FW)
	$(MAKE) BOARD=papilio -f ./Makefile.xilinx

ico_prog:
	icoprog -p < build/racing_game_femto8.bin

papi_prog:
	papilio-prog -vf build/racing_game_femto8.bin

%.hex: %.asm
	node ../../nanoasm/src/asmmain.js femto8/femto8.json $< > $@

clean:
	rm -rf build *.hex
