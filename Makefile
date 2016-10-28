default: build

all: clean build

build:
	cd compiler; make

.PHONY: test clean
test:
	cd compiler; make
	cd test; make

clean:
	cd compiler; make clean
	cd test; make clean
