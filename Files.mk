# Lua 5.4.7
LUA_SRCS = $(patsubst %, lua/%, \
	lapi.c lcode.c lctype.c ldebug.c ldo.c ldump.c \
	lfunc.c lgc.c llex.c lmem.c lobject.c lopcodes.c lparser.c \
	lstate.c lstring.c ltable.c ltm.c lundump.c lvm.c lzio.c \
	lauxlib.c lbaselib.c lcorolib.c ldblib.c liolib.c lmathlib.c \
	loadlib.c loslib.c lstrlib.c ltablib.c lutf8lib.c linit.c \
)
LUA_CFLAGS = -DLUA_COMPAT_5_3 -I lua/

# LuaFFI-FB but with the calling replaced with libffi calling (so I guess I just liked their cdefs parser...  and bit field support .. but their pointer support is limited, only 3 nested ...)
LUAFFIFB_SRCS = $(patsubst %, luaffifb/%, \
	call.c ctype.c ffi.c ffi_complex.c lua.c parser.c \
)
LUAFFIFB_CFLAGS = -I lua/ -I libffi/src/wasm32/include -I libffi/src/wasm32 -DCALL_WITH_LIBFFI 

# this is going to be a pain to configure and compile ... so I haven't yet ...
GNUPLOT_SRCS = $(patsubst %, gnuplot/src/%, \
	alloc.c amos_airy.c axis.c breaders.c boundary.c color.c command.c command.c contour.c complexfun.c datablock.c datafile.c dynarray.c encoding.c \
	eval.c external.c filters.c fit.c gadgets.c getcolor.c graph3d.c graphics.c help.c hidden3d.c history.c internal.c interpol.c jitter.c libcerf.c \
	matrix.c misc.c mouse.c multiplot.c parse.c plot.c plot2d.c plot3d.c pm3d.c readline.c save.c scanner.c set.c show.c specfun.c standard.c stats.c \
	stdfn.c tables.c tabulate.c term.c time.c unset.c util.c util3d.c variable.c version.c voxelgrid.c vplot.c watch.c xdg.c gp_cairo.c gp_cairo_helpers.c \
	bf_test.c gplt_x11.c gpexecute.c getcolor.c checkdoc.c termdoc.c doc2ipf.c xref.c doc2tex.c termdoc.c doc2gih.c doc2rnh.c doc2hlp.c doc2rtf.c doc2ms.c \
	termdoc.c doc2gih.c termdoc.c doc2html.c termdoc.c xref.c doc2web.c termdoc.c xref.c demo_plugin.c \
)

# TODO compile lua to a main module
#  and compile luaffifb and gnuplot to separate side modules
# ... why even have any specific main? lua to a lib as well?  why not only ever side modules?
DIST_SRCS= $(LUA_SRCS) \
	$(LUAFFIFB_SRCS)
	# $(GNUPLOT_SRCS)
DIST_OBJS= $(patsubst %.c, %$(O), $(DIST_SRCS))


# common compile settings to all:

# in both Makefile and Makefile-native
CFLAGS= -Wall -Wextra
LDFLAGS=
