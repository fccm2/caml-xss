XSS_CFLAGS = -I../utils
XSS_CLIBS = -lSM -lICE  -lXt -lX11 -lXext  -lm

XSS_OBJ_O = screenhack.o fps.o ../utils/resources.o ../utils/visual.o ../utils/usleep.o ../utils/yarandom.o ../utils/utf8wc.o ../utils/font-retry.o ../utils/xmu.o ../utils/xft.o  ../utils/xdbe.o ../utils/hsv.o ../utils/colors.o

OCAMLMKLIB = ocamlmklib
OCAMLOPT = ocamlopt
OCAMLC = ocamlc

o: caml_xss_stub.o
so: dllcaml_xss_stub.so
cma: caml_xss.cma
cmxa: caml_xss.cmxa

caml_xss_stub.o: caml_xss_stub.c
	$(OCAMLOPT) -fPIC -c -ccopt "$(XSS_CFLAGS)" $<

caml_xss.cmi: caml_xss.mli
	$(OCAMLC) -c $<

caml_xss.cmo: caml_xss.ml caml_xss.cmi
	$(OCAMLC) -c $<

caml_xss.cmx: caml_xss.ml caml_xss.cmi
	$(OCAMLOPT) -c $<

caml_xss.cma: caml_xss.cmo dllcaml_xss_stub.so
	$(OCAMLC) -a -o $@ $< -dllib dllcaml_xss_stub.so

caml_xss.cmxa: caml_xss.cmx dllcaml_xss_stub.so
	$(OCAMLOPT) -a -o $@ $< -cclib -lcaml_xss_stub -cclib "$(XSS_CLIBS)"

dllcaml_xss_stub.so: caml_xss_stub.o
	$(OCAMLMKLIB) -o caml_xss_stub -ldopt "$(XSS_CLIBS)" $(XSS_OBJ_O) $<

clean:
	$(RM) \
	  caml_xss.[ao] \
	  caml_xss_stub.o \
	  caml_xss.cm[ioxa] \
	  caml_xss.cmxa \
	  dllcaml_xss_stub.so

%.opt: caml_xss_%.ml caml_xss.cmxa
	ocamlopt -I . caml_xss.cmxa $< -o $@

xss_objs.a:
	ar rcs $@ $(XSS_OBJ_O)

USER = caml_xss_user2.ml

run: user2.opt
	./$< -geometry 280x180

%.opt: caml_xss_%.ml caml_xss.cmxa
	ocamlopt -I . caml_xss.cmxa $< -o $@

