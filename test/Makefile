default: test 

test:
	cd scanner; make
	cd parser; make	
	./parser_test.sh
	./scanner_test.sh
.PHONY:
clean: 
	cd scanner; make clean
	cd parser; make clean
