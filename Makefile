ZXBC ?= zxbc
SOURCE := src/main.bas
OUTPUT := build/jemima-vs-the-fish.tap

.PHONY: all test clean

all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	@mkdir -p build
	$(ZXBC) $(SOURCE) -t -B -a -O 2 -o $(OUTPUT)

test:
	python3 -m unittest discover -s tests -v

clean:
	rm -f build/*.tap build/*.bin build/*.asm build/*.tzx
