# -*- makefile -*-
#
# Makefile for building NASM using OpenWatcom
# cross-compile on a DOS/Win32/OS2/Linux platform host
#

top_srcdir  = .
srcdir      = .
VPATH       = .;$(srcdir)/output;$(srcdir)/lib
prefix      = C:\Program Files\NASM
exec_prefix = $(prefix)
bindir      = $(prefix)\bin
mandir      = $(prefix)\man

CC      = *wcl386
DEBUG       =
CFLAGS      = -zq -6 -ox -wx -ze -fpi $(DEBUG)
BUILD_CFLAGS    = $(CFLAGS) $(%TARGET_CFLAGS)
INTERNAL_CFLAGS = -I$(srcdir) -I. -DHAVE_CONFIG_H
ALL_CFLAGS  = $(BUILD_CFLAGS) $(INTERNAL_CFLAGS)
LD      = *wlink
LDEBUG      =
LDFLAGS     = op quiet $(%TARGET_LFLAGS) $(LDEBUG)
LIBS        =
PERL        = perl -I$(srcdir)/perllib -I$(srcdir)

STRIP       = wstrip

# Binary suffixes
O               = obj
X               = .exe

# WMAKE errors out if a suffix is declared more than once, including
# its own built-in declarations.  Thus, we need to explicitly clear the list
# first.  Also, WMAKE only allows implicit rules that point "to the left"
# in this list!
.SUFFIXES:
.SUFFIXES: .man .1 .$(O) .i .c

# Needed to find C files anywhere but in the current directory
.c : $(VPATH)

.c.$(O):
    @set INCLUDE=
    $(CC) -c $(ALL_CFLAGS) -fo=$^@ $[@

#-- Begin File Lists --#
# Edit in Makefile.in, not here!
NASM =	asm/nasm.$(O) &
	asm/float.$(O) &
	asm/directiv.$(O) &
	asm/assemble.$(O) asm/labels.$(O) asm/parser.$(O) &
	asm/preproc.$(O) asm/quote.$(O) asm/pptok.$(O) &
	asm/listing.$(O) asm/eval.$(O) asm/exprlib.$(O) &
	asm/stdscan.$(O) &
	asm/strfunc.$(O) asm/tokhash.$(O) &
	asm/segalloc.$(O) &
	asm/preproc-nop.$(O) &
	asm/rdstrnum.$(O) &
	&
	macros/macros.$(O) &
	&
	output/outform.$(O) output/outlib.$(O) output/legacy.$(O) &
	output/nulldbg.$(O) output/nullout.$(O) &
	output/outbin.$(O) output/outaout.$(O) output/outcoff.$(O) &
	output/outelf.$(O) &
	output/outobj.$(O) output/outas86.$(O) output/outrdf2.$(O) &
	output/outdbg.$(O) output/outieee.$(O) output/outmacho.$(O) &
	output/codeview.$(O)

NDISASM = disasm/ndisasm.$(O) disasm/disasm.$(O) disasm/sync.$(O)

LIBOBJ = stdlib/snprintf.$(O) stdlib/vsnprintf.$(O) stdlib/strlcpy.$(O) &
	stdlib/strnlen.$(O) &
	nasmlib/ver.$(O) &
	nasmlib/crc64.$(O) nasmlib/malloc.$(O) &
	nasmlib/error.$(O) nasmlib/md5c.$(O) nasmlib/string.$(O) &
	nasmlib/file.$(O) nasmlib/ilog2.$(O) &
	nasmlib/realpath.$(O) nasmlib/filename.$(O) nasmlib/srcfile.$(O) &
	nasmlib/zerobuf.$(O) nasmlib/readnum.$(O) nasmlib/bsi.$(O) &
	nasmlib/rbtree.$(O) nasmlib/hashtbl.$(O) &
	nasmlib/raa.$(O) nasmlib/saa.$(O) &
	nasmlib/strlist.$(O) &
	common/common.$(O) &
	x86/insnsa.$(O) x86/insnsb.$(O) x86/insnsd.$(O) x86/insnsn.$(O) &
	x86/regs.$(O) x86/regvals.$(O) x86/regflags.$(O) x86/regdis.$(O) &
	x86/disp8.$(O) x86/iflag.$(O)
#-- End File Lists --#

what:   .SYMBOLIC
    @echo Please build "dos", "win32", "os2" or "linux386"

dos:    .SYMBOLIC
    @set TARGET_CFLAGS=-bt=DOS -I"$(%WATCOM)/h"
    @set TARGET_LFLAGS=sys causeway
    @%make all

win32:  .SYMBOLIC
    @set TARGET_CFLAGS=-bt=NT -I"$(%WATCOM)/h" -I"$(%WATCOM)/h/nt"
    @set TARGET_LFLAGS=sys nt
    @%make all

os2:    .SYMBOLIC
    @set TARGET_CFLAGS=-bt=OS2 -I"$(%WATCOM)/h" -I"$(%WATCOM)/h/os2"
    @set TARGET_LFLAGS=sys os2v2
    @%make all

linux386:   .SYMBOLIC
    @set TARGET_CFLAGS=-bt=LINUX -I"$(%WATCOM)/lh"
    @set TARGET_LFLAGS=sys linux
    @%make all

all: config.h perlreq nasm$(X) ndisasm$(X) .SYMBOLIC
#   cd rdoff && $(MAKE) all

nasm$(X): $(NASM)
    $(LD) $(LDFLAGS) name nasm$(X) file {$(NASM)} $(LIBS)

ndisasm$(X): $(NDISASM)
    $(LD) $(LDFLAGS) name ndisasm$(X) file {$(NDISASM)} $(LIBS)

# These source files are automagically generated from a single
# instruction-table file by a Perl script. They're distributed,
# though, so it isn't necessary to have Perl just to recompile NASM
# from the distribution.

insns.pl: insns-iflags.pl

iflag.c iflag.h: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -t $(srcdir)/insns.dat
insnsb.c: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -b $(srcdir)/insns.dat
insnsa.c: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -a $(srcdir)/insns.dat
insnsd.c: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -d $(srcdir)/insns.dat
insnsi.h: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -i $(srcdir)/insns.dat
insnsn.c: insns.dat insns.pl
    $(PERL) $(srcdir)/insns.pl -n $(srcdir)/insns.dat

# These files contains all the standard macros that are derived from
# the version number.
version.h: version version.pl
    $(PERL) $(srcdir)/version.pl h < $(srcdir)/version > version.h

version.mac: version version.pl
    $(PERL) $(srcdir)/version.pl mac < $(srcdir)/version > version.mac

# This source file is generated from the standard macros file
# `standard.mac' by another Perl script. Again, it's part of the
# standard distribution.

macros.c: macros.pl standard.mac version.mac macros/*.mac output/*.mac
    $(PERL) $<

# These source files are generated from regs.dat by yet another
# perl script.
regs.c: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl c $(srcdir)/regs.dat > regs.c
regflags.c: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl fc $(srcdir)/regs.dat > regflags.c
regdis.c: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl dc $(srcdir)/regs.dat > regdis.c
regdis.h: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl dh $(srcdir)/regs.dat > regdis.h
regvals.c: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl vc $(srcdir)/regs.dat > regvals.c
regs.h: regs.dat regs.pl
    $(PERL) $(srcdir)/regs.pl h $(srcdir)/regs.dat > regs.h

# Assembler token hash
tokhash.c: insns.dat regs.dat tokens.dat tokhash.pl perllib/phash.ph
    $(PERL) $(srcdir)/tokhash.pl c $(srcdir)/insns.dat $(srcdir)/regs.dat &
        $(srcdir)/tokens.dat > tokhash.c

# Assembler token metadata
tokens.h: insns.dat regs.dat tokens.dat tokhash.pl perllib/phash.ph
    $(PERL) $(srcdir)/tokhash.pl h $(srcdir)/insns.dat $(srcdir)/regs.dat &
        $(srcdir)/tokens.dat > tokens.h

# Preprocessor token hash
pptok.h: pptok.dat pptok.pl perllib/phash.ph
    $(PERL) $(srcdir)/pptok.pl h $(srcdir)/pptok.dat pptok.h
pptok.c: pptok.dat pptok.pl perllib/phash.ph
    $(PERL) $(srcdir)/pptok.pl c $(srcdir)/pptok.dat pptok.c
pptok.ph: pptok.dat pptok.pl perllib/phash.ph
    $(PERL) $(srcdir)/pptok.pl ph $(srcdir)/pptok.dat pptok.ph

# Directives hash
directiv.h: directiv.dat directiv.pl perllib/phash.ph
    $(PERL) $(srcdir)/directiv.pl h $(srcdir)/directiv.dat directiv.h
directiv.c: directiv.dat directiv.pl perllib/phash.ph
    $(PERL) $(srcdir)/directiv.pl c $(srcdir)/directiv.dat directiv.c

# This target generates all files that require perl.
# This allows easier generation of distribution (see dist target).
PERLREQ = pptok.ph macros.c insnsb.c insnsa.c insnsd.c insnsi.h insnsn.c &
      regs.c regs.h regflags.c regdis.c regdis.h regvals.c &
      tokhash.c tokens.h pptok.h pptok.c &
      directiv.c directiv.h &
      version.h version.mac &
      iflag.c iflag.h
perlreq: $(PERLREQ) .SYMBOLIC

clean: .SYMBOLIC
    rm -f *.$(O) *.s *.i
    rm -f lib/*.$(O) lib/*.s lib/*.i
    rm -f output/*.$(O) output/*.s output/*.i
    rm -f config.h config.log config.status
    rm -f nasm$(X) ndisasm$(X)
#   cd rdoff && $(MAKE) clean

distclean: clean .SYMBOLIC
    rm -f config.h config.log config.status
    rm -f Makefile *~ *.bak *.lst *.bin
    rm -f output/*~ output/*.bak
    rm -f test/*.lst test/*.bin test/*.$(O) test/*.bin
#   -del /s autom4te*.cache
#   cd rdoff && $(MAKE) distclean

cleaner: clean .SYMBOLIC
    rm -f $(PERLREQ)
    rm -f *.man
    rm -f nasm.spec
#   cd doc && $(MAKE) clean

spotless: distclean cleaner .SYMBOLIC
    rm -f doc/Makefile doc/*~ doc/*.bak

strip: .SYMBOLIC
    $(STRIP) *.exe

rdf:
#   cd rdoff && $(MAKE)

doc:
#   cd doc && $(MAKE) all

everything: all doc rdf

config.h: Mkfiles/openwcom.mak
    @echo Creating $@
    @%create $@
    @%append $@ $#define HAVE_DECL_STRCASECMP 1
    @%append $@ $#define HAVE_DECL_STRICMP 1
    @%append $@ $#define HAVE_DECL_STRLCPY 1
    @%append $@ $#define HAVE_DECL_STRNCASECMP 1
    @%append $@ $#define HAVE_DECL_STRNICMP 1
    @%append $@ $#define HAVE_INTTYPES_H 1
    @%append $@ $#define HAVE_LIMITS_H 1
    @%append $@ $#define HAVE_MEMORY_H 1
    @%append $@ $#define HAVE_SNPRINTF 1
    @%append $@ $#define HAVE_STDBOOL_H 1
    @%append $@ $#define HAVE_STDINT_H 1
    @%append $@ $#define HAVE_STDLIB_H 1
    @%append $@ $#define HAVE_STRCASECMP 1
    @%append $@ $#define HAVE_STRCSPN 1
    @%append $@ $#define HAVE_STRICMP 1
    @%append $@ $#define HAVE_STRINGS_H 1
    @%append $@ $#define HAVE_STRING_H 1
    @%append $@ $#define HAVE_STRLCPY 1
    @%append $@ $#define HAVE_STRNCASECMP 1
    @%append $@ $#define HAVE_STRNICMP 1
    @%append $@ $#define HAVE_STRSPN 1
    @%append $@ $#define HAVE_SYS_STAT_H 1
    @%append $@ $#define HAVE_SYS_TYPES_H 1
    @%append $@ $#define HAVE_UNISTD_H 1
    @%append $@ $#define HAVE_VSNPRINTF 1
    @%append $@ $#define STDC_HEADERS 1

#
# This build dependencies in *ALL* makefiles.  Partially for that reason,
# it's expected to be invoked manually.
#
alldeps: perlreq .SYMBOLIC
    $(PERL) syncfiles.pl Makefile.in Mkfiles/openwcom.mak
    $(PERL) mkdep.pl -M Makefile.in Mkfiles/openwcom.mak -- . output lib

#-- Magic hints to mkdep.pl --#
# @object-ending: ".$(O)"
# @path-separator: "/"
# @exclude: ""
# @continuation: "&"
#-- Everything below is generated by mkdep.pl - do not edit --#
asm/assemble.$(O): asm/assemble.c asm/assemble.h asm/directiv.h &
 asm/listing.h asm/pptok.h asm/preproc.h asm/tokens.h config/config.h &
 config/msvc.h config/unknown.h include/compiler.h include/disp8.h &
 include/iflag.h include/insns.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/strlist.h include/tables.h &
 x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/directiv.$(O): asm/directiv.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/hashtbl.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
asm/eval.$(O): asm/eval.c asm/directiv.h asm/eval.h asm/float.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/labels.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/strlist.h include/tables.h &
 x86/insnsi.h x86/regs.h
asm/exprlib.$(O): asm/exprlib.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/float.$(O): asm/float.c asm/directiv.h asm/float.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
asm/labels.$(O): asm/labels.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/hashtbl.h include/labels.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/strlist.h include/tables.h &
 x86/insnsi.h x86/regs.h
asm/listing.$(O): asm/listing.c asm/directiv.h asm/listing.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
asm/nasm.$(O): asm/nasm.c asm/assemble.h asm/directiv.h asm/eval.h &
 asm/float.h asm/listing.h asm/parser.h asm/pptok.h asm/preproc.h &
 asm/stdscan.h asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/labels.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/raa.h include/saa.h include/strlist.h include/tables.h &
 include/ver.h output/outform.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/parser.$(O): asm/parser.c asm/directiv.h asm/eval.h asm/float.h &
 asm/parser.h asm/pptok.h asm/preproc.h asm/stdscan.h asm/tokens.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/iflag.h include/insns.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/strlist.h include/tables.h &
 x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/pptok.$(O): asm/pptok.c asm/pptok.h asm/preproc.h config/config.h &
 config/msvc.h config/unknown.h include/compiler.h include/hashtbl.h &
 include/nasmint.h include/nasmlib.h
asm/preproc-nop.$(O): asm/preproc-nop.c asm/directiv.h asm/listing.h &
 asm/pptok.h asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
asm/preproc.$(O): asm/preproc.c asm/directiv.h asm/eval.h asm/listing.h &
 asm/pptok.h asm/preproc.h asm/quote.h asm/stdscan.h asm/tokens.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/hashtbl.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
asm/quote.$(O): asm/quote.c asm/quote.h config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
asm/rdstrnum.$(O): asm/rdstrnum.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/segalloc.$(O): asm/segalloc.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/strlist.h &
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/stdscan.$(O): asm/stdscan.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/quote.h asm/stdscan.h asm/tokens.h config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/iflag.h include/insns.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/strfunc.$(O): asm/strfunc.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/tokhash.$(O): asm/tokhash.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/stdscan.h asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/hashtbl.h include/iflag.h include/insns.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
common/common.$(O): common/common.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/strlist.h &
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
disasm/disasm.$(O): disasm/disasm.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h disasm/disasm.h &
 disasm/sync.h include/compiler.h include/disp8.h include/iflag.h &
 include/insns.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/iflaggen.h &
 x86/insnsi.h x86/regdis.h x86/regs.h
disasm/ndisasm.$(O): disasm/ndisasm.c asm/directiv.h asm/pptok.h &
 asm/preproc.h asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 disasm/disasm.h disasm/sync.h include/compiler.h include/iflag.h &
 include/insns.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h include/ver.h &
 x86/iflaggen.h x86/insnsi.h x86/regs.h
disasm/sync.$(O): disasm/sync.c config/config.h config/msvc.h &
 config/unknown.h disasm/sync.h include/compiler.h include/nasmint.h &
 include/nasmlib.h
macros/macros.$(O): macros/macros.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/hashtbl.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h output/outform.h &
 x86/insnsi.h x86/regs.h
nasmlib/bsi.$(O): nasmlib/bsi.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/crc64.$(O): nasmlib/crc64.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/hashtbl.h include/nasmint.h &
 include/nasmlib.h
nasmlib/error.$(O): nasmlib/error.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/file.$(O): nasmlib/file.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/filename.$(O): nasmlib/filename.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/hashtbl.$(O): nasmlib/hashtbl.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/hashtbl.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/strlist.h include/tables.h &
 x86/insnsi.h x86/regs.h
nasmlib/ilog2.$(O): nasmlib/ilog2.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/malloc.$(O): nasmlib/malloc.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/md5c.$(O): nasmlib/md5c.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/md5.h include/nasmint.h
nasmlib/raa.$(O): nasmlib/raa.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h &
 include/raa.h
nasmlib/rbtree.$(O): nasmlib/rbtree.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/rbtree.h
nasmlib/readnum.$(O): nasmlib/readnum.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
nasmlib/realpath.$(O): nasmlib/realpath.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/saa.$(O): nasmlib/saa.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h &
 include/saa.h
nasmlib/srcfile.$(O): nasmlib/srcfile.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/hashtbl.h include/nasmint.h &
 include/nasmlib.h
nasmlib/string.$(O): nasmlib/string.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
nasmlib/strlist.$(O): nasmlib/strlist.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h &
 include/strlist.h
nasmlib/ver.$(O): nasmlib/ver.c include/ver.h version.h
nasmlib/zerobuf.$(O): nasmlib/zerobuf.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
output/codeview.$(O): output/codeview.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/hashtbl.h include/md5.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/saa.h &
 include/strlist.h include/tables.h output/outlib.h output/pecoff.h &
 version.h x86/insnsi.h x86/regs.h
output/legacy.$(O): output/legacy.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/nulldbg.$(O): output/nulldbg.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h output/outlib.h &
 x86/insnsi.h x86/regs.h
output/nullout.$(O): output/nullout.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h output/outlib.h &
 x86/insnsi.h x86/regs.h
output/outaout.$(O): output/outaout.c asm/directiv.h asm/eval.h asm/pptok.h &
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/raa.h include/saa.h include/strlist.h &
 include/tables.h output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outas86.$(O): output/outas86.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/raa.h include/saa.h include/strlist.h &
 include/tables.h output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outbin.$(O): output/outbin.c asm/directiv.h asm/eval.h asm/pptok.h &
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/labels.h include/nasm.h include/nasmint.h &
 include/nasmlib.h include/opflags.h include/saa.h include/strlist.h &
 include/tables.h output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outcoff.$(O): output/outcoff.c asm/directiv.h asm/eval.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/raa.h include/saa.h include/strlist.h &
 include/tables.h output/outform.h output/outlib.h output/pecoff.h &
 x86/insnsi.h x86/regs.h
output/outdbg.$(O): output/outdbg.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h output/outform.h output/outlib.h &
 x86/insnsi.h x86/regs.h
output/outelf.$(O): output/outelf.c asm/directiv.h asm/eval.h asm/pptok.h &
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/raa.h include/rbtree.h include/saa.h &
 include/strlist.h include/tables.h include/ver.h output/dwarf.h &
 output/elf.h output/outelf.h output/outform.h output/outlib.h &
 output/stabs.h x86/insnsi.h x86/regs.h
output/outform.$(O): output/outform.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h output/outform.h &
 x86/insnsi.h x86/regs.h
output/outieee.$(O): output/outieee.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h include/ver.h &
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outlib.$(O): output/outlib.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/outmacho.$(O): output/outmacho.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/raa.h include/rbtree.h include/saa.h &
 include/strlist.h include/tables.h output/outform.h output/outlib.h &
 x86/insnsi.h x86/regs.h
output/outobj.$(O): output/outobj.c asm/directiv.h asm/eval.h asm/pptok.h &
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h include/ver.h &
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outrdf2.$(O): output/outrdf2.c asm/directiv.h asm/pptok.h &
 asm/preproc.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/rdoff.h include/saa.h include/strlist.h &
 include/tables.h output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
stdlib/snprintf.$(O): stdlib/snprintf.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
stdlib/strlcpy.$(O): stdlib/strlcpy.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h
stdlib/strnlen.$(O): stdlib/strnlen.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h
stdlib/vsnprintf.$(O): stdlib/vsnprintf.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/nasmlib.h
x86/disp8.$(O): x86/disp8.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/disp8.h include/nasm.h include/nasmint.h include/nasmlib.h &
 include/opflags.h include/strlist.h include/tables.h x86/insnsi.h &
 x86/regs.h
x86/iflag.$(O): x86/iflag.c config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/nasmint.h x86/iflaggen.h
x86/insnsa.$(O): x86/insnsa.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/strlist.h &
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsb.$(O): x86/insnsb.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/strlist.h &
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsd.$(O): x86/insnsd.c asm/directiv.h asm/pptok.h asm/preproc.h &
 asm/tokens.h config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/iflag.h include/insns.h include/nasm.h &
 include/nasmint.h include/nasmlib.h include/opflags.h include/strlist.h &
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsn.$(O): x86/insnsn.c config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasmint.h include/tables.h x86/insnsi.h
x86/regdis.$(O): x86/regdis.c x86/regdis.h x86/regs.h
x86/regflags.$(O): x86/regflags.c asm/directiv.h asm/pptok.h asm/preproc.h &
 config/config.h config/msvc.h config/unknown.h include/compiler.h &
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h &
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
x86/regs.$(O): x86/regs.c config/config.h config/msvc.h config/unknown.h &
 include/compiler.h include/nasmint.h include/tables.h x86/insnsi.h
x86/regvals.$(O): x86/regvals.c config/config.h config/msvc.h &
 config/unknown.h include/compiler.h include/nasmint.h include/tables.h &
 x86/insnsi.h
