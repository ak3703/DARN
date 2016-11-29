default: build

all: clean build

build:
	cd compiler; make

.PHONY: test clean
test:
	make clean
	cd compiler; make test;
	cd test; make

clean:
	cd compiler; make clean
	cd test; make clean
