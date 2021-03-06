# Generated automatically from Makefile.in by configure.
# $Header: /home/amb/cxref/RCS/Makefile.in 1.15 2002/04/21 17:03:46 amb Exp $
#
# C Cross Referencing & Documentation tool. Version 1.5d.
#
# Program Makefile.
#
# Written by Andrew M. Bishop
#
# This file Copyright 1995,96,97,98,99,2000,01,02 Andrew M. Bishop
# It may be distributed under the GNU Public License, version 2, or
# any higher version.  See section COPYING of the GNU Public license
# for conditions under which this file may be redistributed.
#

# autoconf things

objdir=/home/cs/cs_guest/dessgi/DESS2002-2003/v1.0/cxref
srcdir=.

# The installation locations

prefix=/usr/local
exec_prefix=${prefix}
bindir=$(DESTDIR)${exec_prefix}/bin
mandir=$(DESTDIR)${prefix}/man

# The installation program.

INSTALL=/usr/bin/install -c

# The C compiler and linker

CC=gcc
LD=gcc

CFLAGS=-g -O2
LDFLAGS=

# The Yacc program

YACC=bison -y

YACCFLAGS=-d
BISONFLAGS=-d

# The Lex Program

LEX=flex

LEXFLAGS=
FLEXFLAGS=-pp -B -F -8 -s

# The Perl program

PERL=perl

# The LaTeX and dvips programs

LATEX=latex
DVIPS=dvips

# The page size (for LaTeX and RTF).
# (A4 or US only.)

PAGE=A4

########

INCLUDE=-I.
LIBRARY=

########

programs : cxref-cpp cxref cxref-inst cxref-query

docs : readme faq-html
	cd doc && $(MAKE)

all : programs docs

########

OBJ_FILES=func.o type.o var.o preproc.o comment.o file.o \
          slist.o memory.o \
          xref.o \
          warn-raw.o latex.o latex-style.o html.o rtf.o sgml.o \
          parse-lex.o parse-yacc.o

cxref : cxref.o $(OBJ_FILES)
	$(LD) $(LDFLAGS) cxref.o $(OBJ_FILES) -o $@ $(LIBRARY)

cxref-inst : cxref-inst.o $(OBJ_FILES)
	$(LD) $(LDFLAGS) cxref-inst.o $(OBJ_FILES) -o $@ $(LIBRARY)

####

cxref-cpp :
	cd cpp && $(MAKE) programs

####

cxref-query :
	cd query && $(MAKE) programs

########

faq-html : FAQ FAQ-html.pl
	[ "x$(PERL)" = "x" ] || $(PERL) $(srcdir)/FAQ-html.pl < $(srcdir)/FAQ > FAQ.html

####

readme : programs README.c
	cd $(srcdir) && $(objdir)/cxref -O$(objdir)/doc -NREADME -xref README.c
	cd $(srcdir) && $(objdir)/cxref -O$(objdir)/doc -NREADME -xref README.c -latex2e -html32-src -rtf -sgml
	cp doc/README.c.tex      README_c.tex
	cp doc/README.c.html     README.c.html
	cp doc/README.c.src.html README.c.src.html
	cp doc/README.c.rtf      README.c.rtf
	cp doc/README.c.sgml     README.c.sgml
	[ "x$(LATEX)" = "x" ] || $(LATEX) README.tex > /dev/null 2>&1
	[ "x$(LATEX)" = "x" ] || $(LATEX) README.tex
	[ "x$(DVIPS)" = "x" ] || $(DVIPS) README.dvi -o README.ps
	@rm -f README.aux README.log README.toc doc/README.*

########

install : programs
	[ -d $(bindir) ] || $(INSTALL) -d $(bindir)
	$(INSTALL) -m 755 cxref-inst $(bindir)/cxref
	$(INSTALL) -m 755 $(srcdir)/cxref-cc $(bindir)
	[ -d $(mandir)/man1 ] || $(INSTALL) -d $(mandir)/man1
	$(INSTALL) -m 644 $(srcdir)/README.man $(mandir)/man1/cxref.1
	cd cpp && $(MAKE) install
	cd query && $(MAKE) install

install-win32 : programs
	[ -d $(bindir) ] || $(INSTALL) -d $(bindir)
	$(INSTALL) -m 755 cxref-inst.exe $(bindir)/cxref.exe
	$(INSTALL) -m 755 cxref-cc $(bindir)
	cd cpp && $(MAKE) install-win32
	cd query && $(MAKE) install-win32

########

clean :
	-rm -f cxref cxref-inst core *.o *~ \
	lex.*.c y.tab.* latex-style.c \
	parse-yacc.c parse-yacc.h parse-lex.c \
	README.dvi README.ps
	cd cpp && $(MAKE) clean
	cd doc && $(MAKE) clean
	cd query && $(MAKE) clean

####

distclean : clean
	-rm -f Makefile autoconfig.h \
	config.log config.status config.cache
	cd cpp && $(MAKE) distclean
	cd doc && $(MAKE) distclean
	cd query && $(MAKE) distclean

########

parse-yacc.c : parse.y
	[ ! "$(YACC)" = "bison" ] || $(YACC) $(BISONFLAGS) $(srcdir)/parse.y
	[   "$(YACC)" = "bison" ] || $(YACC) $(YACCFLAGS)  $(srcdir)/parse.y
	-@mv y.tab.c  parse-yacc.c
	@echo Created parse-yacc.c

parse-yacc.h : parse-yacc.c
	-@if cmp -s parse-yacc.h y.tab.h ; then : ; else \
	   if [ -f y.tab.h ] ; then \
	      cp y.tab.h parse-yacc.h ; \
	      echo Created parse-yacc.h ; \
	   fi \
	fi

####

parse-lex.c : parse.l
	[ ! "$(LEX)" = "flex" ] || $(LEX) $(FLEXFLAGS) $(srcdir)/parse.l
	[   "$(LEX)" = "flex" ] || $(LEX) $(LEXFLAGS)  $(srcdir)/parse.l
	-@mv lex.yy.c parse-lex.c
	@echo Created parse-lex.c

####

latex-style.c : $(srcdir)/doc/fonts.style $(srcdir)/doc/page.style $(srcdir)/doc/cxref.style
	@echo '/** The style files needed for LaTeX. **/' >  latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The fonts style file as a string. +*/' >> latex-style.c
	@echo 'char *latex_fonts_style='                  >> latex-style.c
	@sed 's/\\/\\\\/g' $(srcdir)/doc/fonts.style \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The page style file as a string. +*/'  >> latex-style.c
	@echo 'char *latex_page_style='                   >> latex-style.c
	@sed 's/	CONFIG-ONLY PAGE=$(PAGE)//g' $(srcdir)/doc/page.style \
	|grep -v 'CONFIG-ONLY' \
	|sed 's/\\/\\\\/g' \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The cxref style file as a string. +*/' >> latex-style.c
	@echo 'char *latex_cxref_style='                  >> latex-style.c
	@sed 's/\\/\\\\/g' $(srcdir)/doc/cxref.style \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo Created latex-style.c

####

.SUFFIXES:
.SUFFIXES: .c .o

.c.o:
	$(CC) -c $(CFLAGS) $< -o $@ $(INCLUDE) -I.

cxref.o      : cxref.c      cxref.h datatype.h memory.h parse-yy.h
	[ ! -f cpp/cxref-cpp ] || $(CC) -c $(CFLAGS) $(srcdir)/cxref.c -o $@ $(INCLUDE) "-DCXREF_CPP=\"$$PWD/cpp/cxref-cpp -C -dD -dI\""
	[   -f cpp/cxref-cpp ] || $(CC) -c $(CFLAGS) $(srcdir)/cxref.c -o $@ $(INCLUDE) "-DCXREF_CPP=\"$(CC) -E -C -dD -dI\""

cxref-inst.o : cxref.c      cxref.h datatype.h memory.h parse-yy.h
	[ ! -f cpp/cxref-cpp ] || $(CC) -c $(CFLAGS) $(srcdir)/cxref.c -o $@ $(INCLUDE) '-DCXREF_CPP="cxref-cpp -C -dD -dI"'
	[   -f cpp/cxref-cpp ] || $(CC) -c $(CFLAGS) $(srcdir)/cxref.c -o $@ $(INCLUDE) "-DCXREF_CPP=\"$(CC) -E -C -dD -dI\""

func.o       : func.c       cxref.h datatype.h memory.h parse-yy.h
type.o       : type.c       cxref.h datatype.h memory.h parse-yy.h
var.o        : var.c        cxref.h datatype.h memory.h parse-yy.h
comment.o    : comment.c    cxref.h datatype.h memory.h
file.o       : file.c       cxref.h datatype.h memory.h
preproc.o    : preproc.c    cxref.h datatype.h memory.h parse-yy.h

slist.o      : slist.c      cxref.h datatype.h memory.h
memory.o     : memory.c                        memory.h

xref.o       : xref.c       cxref.h datatype.h memory.h

warn-raw.o   : warn-raw.c   cxref.h datatype.h memory.h
latex.o      : latex.c      cxref.h datatype.h memory.h
latex-style.o: latex-style.c
html.o       : html.c       cxref.h datatype.h memory.h
rtf.o        : rtf.c        cxref.h datatype.h memory.h
	$(CC) -c $(CFLAGS) $(srcdir)/rtf.c -o $@ -DPAGE=\"$(PAGE)\" $(INCLUDE)
sgml.o       : sgml.c       cxref.h datatype.h memory.h

parse-yacc.o : parse-yacc.c cxref.h datatype.h memory.h parse-yy.h parse-yacc.h
parse-lex.o  : parse-lex.c  cxref.h datatype.h memory.h parse-yy.h parse-yacc.h

########
