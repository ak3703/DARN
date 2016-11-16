OBJS = ../../compiler/scanner.cmo ../../compiler/parser.cmo ../../compiler/ast.cmo ../../compiler/semant.cmo parserize.cmo
INCLUDES =  -I ../../compiler

default: parserize

parserize: $(OBJS)
	ocamlc $(INCLUDES) -o parserize $(OBJS)

%.cmo : %.ml
	ocamlc $(INCLUDES) -c $<

%.cmi : %.mli
	ocamlc $(INCLUDES) -c $<

.PHONY : clean
clean :
	rm -f parserize *.cmo *.cmi
