OCAMLINIT_PATH = "/home/fica/.ocamlinit"

OCB_FLAGS = -use-menhir -tag thread -use-ocamlfind -quiet -pkg core
OCB = corebuild $(OCB_FLAGS)


clean: 
	$(OCB) -clean
	rm -f .ocamlinit_tmp

benchmarks_msorts:
	$(OCB) benchmarks_msorts.native
	./benchmarks_msorts.native

test:
	$(OCB) test.native
	./test.native

proof_checker: clean parser.cmo lexer.cmo rules.cmo natural_deduction.cmo
	$(OCB) proof_checker.native 

%.native:
	$(OCB) $@

%.byte:
	$(OCB) $@

%.cmo:
	$(OCB) $@

%.mli:
	$(OCB) $@

%.top: %.cmo
	cat $(OCAMLINIT_PATH) > .ocamlinit_tmp
	for file in $(shell find ./_build -type d); do \
		echo "#directory \"$$file\";;" >> .ocamlinit_tmp;\
	done
	echo '#load_rec "$<";;' >> .ocamlinit_tmp
	utop -init .ocamlinit_tmp