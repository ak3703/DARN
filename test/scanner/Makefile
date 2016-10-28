OBJS = ../../compiler/scanner.cmo tokenize.cmo
INCLUDES = -I ../../compiler

default: tokenize

tokenize: $(OBJS)
	ocamlc $(INCLUDES) -o tokenize $(OBJS)

%.cmo : %.ml
	ocamlc $(INCLUDES) -c $<

%.cmi : %.mli
	ocamlc $(INCLUDES) -c $<

.PHONY : clean
clean :
	rm -f tokenize *.cmo *.cmi


