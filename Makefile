.PHONY: all clean dist

# TODO
# - do things in a more portable way
# - declare some of these tools as dependencies the end user has to install themselves
# - find an alternative to auracomp for LZ10 compression and decompression?
# - fix a better way to run Python 2.7, or fix darc incompatibility with Python 3

AURACOMP  := /l/Logiciels/.CLI/auracomp/auracomp.exe
BCLIMTOOL := tools/bclimtool.exe
DARCTOOL  := py -2.7 tools/darc.py

all: dist

# TODO
dist: out/AccountHeader.arc

# TODO
#out/code.ips: code.ips src/main.s
#	@mkdir -p build out
#	@armips src/main.s
#	@flips -c code.bin build/patched_code.bin out/code.ips

build/%.bclim: data/%.png
	mkdir -p build
	$(BCLIMTOOL) -cvtfp RGBA4444 $@ $<

out/AccountHeader.arc: AccountHeader.arc build/PNIcon_00.bclim
	mkdir -p out
	rm -rf build/AccountHeader.d
	sha256sum --quiet -c AccountHeader.arc.sha256
	$(AURACOMP) -d -algo LZ10 -in AccountHeader.arc -out build/AccountHeader.arc -overwrite -quiet
	$(DARCTOOL) -x -f build/AccountHeader.arc -d build/AccountHeader.d
	cp build/PNIcon_00.bclim build/AccountHeader.d/timg/NNIcon_00.bclim
	flips -a act-patch/src/AccountHeader.bclyt.ips build/AccountHeader.d/blyt/AccountHeader.bclyt build/AccountHeader.bclyt
	mv build/AccountHeader.bclyt build/AccountHeader.d/blyt/AccountHeader.bclyt
	$(DARCTOOL) -c -t "*.bclim:0x80" -f build/AccountHeader.arc -d build/AccountHeader.d
	$(AURACOMP) -c -a LZ10 -l 15 -in build/AccountHeader.arc -out out/AccountHeader.arc -overwrite -quiet

clean:
	rm -rf build out
