####################################################################################
#                OCaml-lru-cache                                                   #
#                                                                                  #
#    Copyright (C) 2012-2015 Institut National de Recherche en Informatique        #
#    et en Automatique. All rights reserved.                                       #
#                                                                                  #
#    This program is free software; you can redistribute it and/or modify          #
#    it under the terms of the GNU Lesser General Public License version           #
#    3 as published by the Free Software Foundation.                               #
#                                                                                  #
#    This program is distributed in the hope that it will be useful,               #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of                #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                 #
#    GNU Library General Public License for more details.                          #
#                                                                                  #
#    You should have received a copy of the GNU Lesser General Public              #
#    License along with this program; if not, write to the Free Software           #
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                      #
#    02111-1307  USA                                                               #
#                                                                                  #
#    Contact: Maxence.Guesdon@inria.fr                                             #
#                                                                                  #
#                                                                                  #
####################################################################################

# DO NOT FORGET TO UPDATE META FILE
VERSION=0.1.0

OCAMLFIND=ocamlfind
PACKAGES=
COMPFLAGS=-annot -safe-string -g
OCAMLPP=
OCAMLLIB:=`$(OCAMLC) -where`

INSTALLDIR=$(OCAMLLIB)

RM=rm -f
CP=cp -f
MKDIR=mkdir -p

LIB=lru-cache.cmxa
LIB_CMXS=$(LIB:.cmxa=.cmxs)
LIB_A=$(LIB:.cmxa=.a)
LIB_BYTE=$(LIB:.cmxa=.cma)
LIB_CMI=$(LIB:.cmxa=.cmi)

LIB_CMXFILES= lru_cache.cmx
LIB_CMOFILES=$(LIB_CMXFILES:.cmx=.cmo)
LIB_CMIFILES=$(LIB_CMXFILES:.cmx=.cmi)
LIB_OFILES=$(LIB_CMXFILES:.cmx=.o)

all: byte opt
byte: $(LIB_BYTE)
opt: $(LIB) $(LIB_CMXS)

$(LIB): $(LIB_CMIFILES) $(LIB_CMXFILES)
	$(OCAMLFIND) ocamlopt -o $@ -a $(LIB_CMXFILES)

$(LIB_CMXS): $(LIB_CMIFILES) $(LIB_CMXFILES)
	$(OCAMLFIND) ocamlopt -shared -o $@ $(LIB_CMXFILES)

$(LIB_BYTE): $(LIB_CMIFILES) $(LIB_CMOFILES)
	$(OCAMLFIND) ocamlc -o $@ -a $(LIB_CMOFILES)

%.cmx: %.ml %.cmi
	$(OCAMLFIND) ocamlopt -c $(COMPFLAGS) $<

%.cmo: %.ml %.cmi
	$(OCAMLFIND) ocamlc -c $(COMPFLAGS) $<

%.cmi: %.mli
	$(OCAMLFIND) ocamlc -c $(COMPFLAGS) $<

.PHONY: test

test: test_lwt
	./$<

test_lwt: test_lwt.ml
	$(OCAMLFIND) ocamlopt -o $@ -package lwt.unix -linkpkg $(LIB) $<


##########
.PHONY: doc
dump.odoc:
	$(OCAMLFIND) ocamldoc -dump $@ lru_cache.mli

doc: dump.odoc
	$(MKDIR) doc
	$(OCAMLFIND) ocamldoc -load $^ -t Lru_cache  -d doc -html

docstog: dump.odoc
	$(MKDIR) web/refdoc
	ocamldoc.opt \
	-t "Lru_cache reference documentation" \
	-load $^ -d web/refdoc -i `ocamlfind query stog` -g odoc_stog.cmxs

##########
install: $(LIB_BYTE)
	$(OCAMLFIND) install lru-cache META LICENSE \
		$(LIB) $(LIB_CMXS) $(LIB_OFILES) $(LIB_CMXFILES) $(LIB_A) \
		$(LIB_BYTE) $(LIB_CMIFILES)

uninstall:
	ocamlfind remove lru-cache

# archive :
###########
archive:
	git archive --prefix=ocaml-lru-cache-$(VERSION)/ HEAD | gzip > ../lru-cache-gh-pages/ocaml-lru-$(VERSION).tar.gz

#####
clean:
	$(RM) *.cm* *.o *.annot *.a dump.odoc

# headers :
###########
HEADFILES=Makefile *.ml *.mli
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)

# depend :
##########

.PHONY: depend

.depend depend:
	$(OCAMLFIND) ocamldep `ls *.ml *.mli` > .depend

include .depend