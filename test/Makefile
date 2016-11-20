default: test 

test:
	cd scanner; make
	cd parser; make	
	./scanner_test.sh
	./parser_test.sh
	./compiler_test.sh
.PHONY:
clean: 
	cd scanner; make clean
	cd parser; make clean
