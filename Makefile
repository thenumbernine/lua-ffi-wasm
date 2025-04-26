# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy:

CFLAGS= -Wall -Wextra -DLUA_COMPAT_5_3 -I lua/
#CFLAGS+=  -std=gnu99
LDFLAGS=




############ clang, since emcc is wedging in tons of c++ crap, mangling symbol names, etc
#	# osx notice: use brew clang since builtin clang is a few versions behind and doesn't yet have wasm target:
#	#   `export PATH=/usr/local/opt/llvm/bin:$PATH`
#	CC=clang
#	#CC=clang++
#	O=.o	# .bc ?
#	DIST=lua-5.4.7-with-ffi.wasm	# .bca ?
#	
#	# wasi-libc I built myself .. still missingruntimes,
#	#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot
#	#LDFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot
#	# so just using `brew install wasi-libc wasi-runtimes`
#	# and now <complex.h> doesn't work, so what went wrong
#	CFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot	# works
#	#LDFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot	 # can't find -lc++ -lc++abi
#	#LDFLAGS+= --sysroot /usr/local/Cellar/wasi-runtimes/19.1.7/share/wasi-sysroot # can't find -lc -ldl etc ...
#	# adding LDFLAGS also causes link errors of looking for some c++ abi
#	# I suspect I shouldn't need to add either ... and that the wasi brew distribution is deficient?  or the brew configuration is messed up (since I'm export PATH this whole thing)
#	
#	#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/build # why ask me for an install dir if you're just going to install to ./sysroot ?
#	#CFLAGS+= --target=wasm32-wasi # works
#	#CFLAGS+= --target=wasm64 # 'string.h' file not found
#	#CFLAGS+= --target=wasm64-wasi # 'string.h' file not found
#	#CFLAGS+= --target=wasm64-unknown-wasi # 'string.h' file not found
#	CFLAGS+= --target=wasm32-unknown-wasi # works
#	LDFLAGS+= --target=wasm32-unknown-wasi
#	CFLAGS+= -O2
#	
#	# for signals:
#	CFLAGS+= -D_WASI_EMULATED_SIGNAL
#	LDFLAGS+= -lwasi-emulated-signal
#	
#	# for longjmp ...
#	CFLAGS+= -mllvm -wasm-enable-sjlj
#	# .. alternatively just compile ldo as C++ ( everything as C++?) and Lua will use throw instead:
#	#CFLAGS+= -x c++ #-std=c++11
#	#LDFLAGS+= -lc++ -lc++abi
#	#CFLAGS+= -fno-exceptions # but I want to use exception based lua errors
#	# but then I get link errors of `undefined symbol: __cxa_allocate_exception` so back to C...
#	#CFLAGS+= "-DLUA_API=extern \"C\""	# without this the luaffifb can't see lua functions, cuz it expects lua's functions to be in C and not C++
#	
#	# tmpfile() is deprecated & L_tmpnam are missing on wasi-libc, so I made this flag to tell Lua build to get around that, and use the LUA_USE_POSIX tmpfile option:
#	CFLAGS+= -DLUA_TMPFILE_MISSING
#	
#	# for clock() to work:
#	CFLAGS+= -D_WASI_EMULATED_PROCESS_CLOCKS
#	LDFLAGS+= -lwasi-emulated-process-clocks
#	
#	# mmap:
#	CFLAGS+= -D_WASI_EMULATED_MMAN
#	LDFLAGS+= -lwasi-emulated-mman
#	
#	# for luaffifb to tell the arch
#	CFLAGS+= -D__WASM__
#	
#	LDFLAGS+= -ldl	# dlopen/dlsym
#	
#	# "Despite claiming to be ISO C, iOS does not implement 'system'."
#	#CFLAGS+= -DLUA_USE_IOS
#	# but if you enable this it causes lots more compile/link errors to pop up ... so ...
#	CFLAGS+= -DLUA_MISSING_SYSTEM
#	
#	LDFLAGS+= -Wl,--export-all	# where'd my symbols go?
#	
#	# now for porting all those emscripten flags to clang flags (in emscripten's libexec/tools/building.py)
#	LDFLAGS+= -Wl,--growable-table -Wl,--max-memory=2147483648




############ emcc final:
	CC=emcc
	O=.o	# .bc?
	DIST=lua-5.4.7-with-ffi.js
	DIST_WASM=lua-5.4.7-with-ffi.wasm
	CFLAGS+= -g2		# keep all debug info
	LDFLAGS+= -g2		# keep all debug info
	#CFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
	#CFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
	##	-target=wasm64-unknown-emscripten
	#LDFLAGS+=- -no-debug -target=wasm64-unknown-emscripten -panic=trap -scheduler=none
	#LDFLAGS+= --profiling-funcs
	#LDFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
	#LDFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
	CFLAGS+= -O3
	LDFLAGS+= -O3
	CFLAGS+= -fPIC
	CFLAGS+= -s MAIN_MODULE=1
	LDFLAGS+= --no-entry
	LDFLAGS+= -s MAIN_MODULE=1
	LDFLAGS+= -s EXPORT_ALL=1
	LDFLAGS+= -s FILESYSTEM=1
	LDFLAGS+= -s ALLOW_TABLE_GROWTH=1	# without it no dynamic stuff I guess?
	LDFLAGS+= -s ALLOW_MEMORY_GROWTH=1	# otherwise my apps die after a few seconds
	LDFLAGS+= -s TOTAL_MEMORY=512MB		# https://stackoverflow.com/questions/55884378/why-in-webassembly-does-allow-memory-growth-1-fail-while-total-memory-512mb-succ
	#LDFLAGS+= -s USE_ZLIB=1				# where is the symbols to this?!?! not being exported!!! wtf!!!
	#LDFLAGS+= -s MEMORY64=1				# otherwise I'm getting the weird case that void*'s are 4bytes but structs-of-void*'s align to 8 bytes ...
	LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS"]'




############ native arch testing:
#	CC=clang
#	O=.o
#	DIST=lua.out	# because 'lua' is a submodule - name in the dir is already used
#	CFLAGS+= -O2 -fPIC
#	LUA_SRCS+= lua/lua.c




.PHONY: all clean
all: $(DIST)

clean:
	-rm $(DIST_OBJS) $(DIST)



# Lua 5.4.7
LUA_SRCS = $(patsubst %, lua/%, \
	lapi.c lcode.c lctype.c ldebug.c ldo.c ldump.c \
	lfunc.c lgc.c llex.c lmem.c lobject.c lopcodes.c lparser.c \
	lstate.c lstring.c ltable.c ltm.c lundump.c lvm.c lzio.c \
	lauxlib.c lbaselib.c lcorolib.c ldblib.c liolib.c lmathlib.c \
	loadlib.c loslib.c lstrlib.c ltablib.c lutf8lib.c linit.c \
)
LUA_OBJS = $(patsubst %.c, %$(O), $(LUA_SRCS))


LUAFFIFB_SRCS = $(patsubst %, luaffifb/%, \
	call.c ctype.c ffi.c parser.c \
)
LUAFFIFB_OBJS = $(patsubst %.c, %$(O), $(LUAFFIFB_SRCS))


# this is going to be a pain to configure and compile ...
GNUPLOT_SRCS = $(patsubst %, gnuplot/src/%, \
	alloc.c amos_airy.c axis.c breaders.c boundary.c color.c command.c command.c contour.c complexfun.c datablock.c datafile.c dynarray.c encoding.c \
	eval.c external.c filters.c fit.c gadgets.c getcolor.c graph3d.c graphics.c help.c hidden3d.c history.c internal.c interpol.c jitter.c libcerf.c \
	matrix.c misc.c mouse.c multiplot.c parse.c plot.c plot2d.c plot3d.c pm3d.c readline.c save.c scanner.c set.c show.c specfun.c standard.c stats.c \
	stdfn.c tables.c tabulate.c term.c time.c unset.c util.c util3d.c variable.c version.c voxelgrid.c vplot.c watch.c xdg.c gp_cairo.c gp_cairo_helpers.c \
	bf_test.c gplt_x11.c gpexecute.c getcolor.c checkdoc.c termdoc.c doc2ipf.c xref.c doc2tex.c termdoc.c doc2gih.c doc2rnh.c doc2hlp.c doc2rtf.c doc2ms.c \
	termdoc.c doc2gih.c termdoc.c doc2html.c termdoc.c xref.c doc2web.c termdoc.c xref.c demo_plugin.c \
)
GNUPLOT_OBJS = $(patsubst %.c, %$(O), $(GNUPLOT_SRCS))


# TODO compile lua to a main module 
#  and compile luaffifb and gnuplot to separate side modules
# ... why even have any specific main? lua to a lib as well?  why not only ever side modules?
DIST_SRCS= $(LUA_SRCS) $(LUAFFIFB_SRCS) 
	# $(GNUPLOT_SRCS)
DIST_OBJS= $(patsubst %.c, %$(O), $(DIST_SRCS))
	

# compile rule for all:
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final
$(DIST): $(DIST_OBJS)
	# idk what emscripten was thinking, but i need a SIDE_MODULE in order to use dlopen, even if nothing is in it...
	emcc -c __tmp_emscripten_sidemodule_empty.c -s SIDE_MODULE=1 -o __tmp_emscripten_sidemodule_empty.o
	emcc __tmp_emscripten_sidemodule_empty.o -s SIDE_MODULE=1 -o __tmp_emscripten_sidemodule_empty.wasm
	# and now I guess I compile everything at once.
	$(CC) $(LDFLAGS) __tmp_emscripten_sidemodule_empty.wasm -o $@ $^
	# and now I'm stuck with shitty old pre-es6 javascript code
	echo 'const init = (Module) => new Promise((initResolve, initReject) => {' | cat - $(DIST) > temp && mv temp $(DIST)
	echo 'addOnPostRun(() => { initResolve(Module); }); }); export {init};' >> $(DIST)
