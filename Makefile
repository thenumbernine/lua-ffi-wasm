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
	CFLAGS+= -O3		# needs O3 or it will error when trying to load the (complete empty but necessary to gain js access to dlopen/dlsym) side module wasm.
	LDFLAGS+= -O3
	#CFLAGS+= -O1
	#LDFLAGS+= -O1
	#CFLAGS+= -O0		# for some reason -O0 tells the js module wasm loader to load twice in async, and the 2nd load complains that the first load isn't finished.....smh
	#LDFLAGS+= -O0		#
	#CFLAGS+= -fwasm-exceptions	# gave me all sorts of "missing ___cxx_exception" problems
	#CFLAGS+= -x c++			# I only want this for Lua (right?)
	CFLAGS+= -fPIC
	LDFLAGS+= -s WASM=1
	#CFLAGS+= -s MEMORY64=1			# this will make you need to change every function arg from js -> emcc to wrap in BigInt, which is frustrating and absurd ...
	#LDFLAGS+= -s MEMORY64=1
	LDFLAGS+= --no-entry
	CFLAGS+= -s MAIN_MODULE=2		# I need this to use dlopen/dlsym
	LDFLAGS+= -s MAIN_MODULE=2
	LDFLAGS+= -s MODULARIZE=1
	#CFLAGS+= -s STRICT=1			# setting STRICT makes emscripten (only with MAIN_MODULE?) request some mystery function __syscall_mprotect which isn't there, and telling it to ignore itself just gets more memory errors at runtime
	#LDFLAGS+= -s STRICT=1
	LDFLAGS+= -s EXPORT_ES6=1
	#LDFLAGS+= -s MALLOC=emmalloc
	LDFLAGS+= -s EXPORT_ALL=1
	LDFLAGS+= -s FILESYSTEM=1
	#LDFLAGS+= -s DEFAULT_TO_CXX=0		# if MAIN_MODULE/SIDE_MODULE isn't used then setting this to 0 will stop the _ underscore in front of C funciton names. fucking retarded.
	LDFLAGS+= -s ALLOW_TABLE_GROWTH=1	# need this for adding functions at runtime
	LDFLAGS+= -s ALLOW_MEMORY_GROWTH=1	# otherwise my apps die after a few seconds ... I suspect whenever memory grows, something gets invalidated and my next lua coroutine resume errors with "memory out of bounds"
	LDFLAGS+= -s INITIAL_MEMORY=3900mb
	#LDFLAGS+= -s INITIAL_HEAP=1gb		# can't do this because nonsense
	LDFLAGS+= -s STACK_SIZE=5mb				# default is 64kb
	CFLAGS+= -s USE_ZLIB=1
	LDFLAGS+= -s USE_ZLIB=1
	CFLAGS+= -s USE_LIBPNG=1
	LDFLAGS+= -s USE_LIBPNG=1
	CFLAGS+= -s USE_LIBJPEG=1
	LDFLAGS+= -s USE_LIBJPEG=1
	CFLAGS+= -s USE_SDL=2
	LDFLAGS+= -s USE_SDL=2
	LDFLAGS+= -s ENVIRONMENT="web"
	#LDFLAGS+= -s WASM_ASYNC_COMPILATION=0	# js init complains if I disable this 
	#LDFLAGS+= -s ERROR_ON_UNDEFINED_SYMBOLS=0	# because emscripten wants some internal function __syscall_mprotect but it's internal to emscripten so it just errors for no fucking reason
	LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS","stringToNewUTF8","addFunction"]'
	LDFLAGS+= -s EXPORTED_FUNCTIONS="[ \
		'_malloc', \
		'_free', \
		'_strlen', \
		'_strerror', \
		'_dlopen', \
		'_dlsym', \
		'_realloc', \
		'_fopen', \
		'_fclose', \
		'_fread', \
		'_gettimeofday', \
		'_SDL_Init', \
		'_luaL_checkversion_', \
		'_luaL_getmetafield', \
		'_luaL_callmeta', \
		'_luaL_tolstring', \
		'_luaL_argerror', \
		'_luaL_typeerror', \
		'_luaL_checklstring', \
		'_luaL_optlstring', \
		'_luaL_checknumber', \
		'_luaL_optnumber', \
		'_luaL_checkinteger', \
		'_luaL_optinteger', \
		'_luaL_checkstack', \
		'_luaL_checktype', \
		'_luaL_checkany', \
		'_luaL_newmetatable', \
		'_luaL_setmetatable', \
		'_luaL_testudata', \
		'_luaL_checkudata', \
		'_luaL_where', \
		'_luaL_fileresult', \
		'_luaL_execresult', \
		'_luaL_ref', \
		'_luaL_unref', \
		'_luaL_loadfilex', \
		'_luaL_loadbufferx', \
		'_luaL_loadstring', \
		'_luaL_newstate', \
		'_luaL_len', \
		'_luaL_addgsub', \
		'_luaL_gsub', \
		'_luaL_setfuncs', \
		'_luaL_getsubtable', \
		'_luaL_traceback', \
		'_luaL_requiref', \
		'_luaL_buffinit', \
		'_luaL_prepbuffsize', \
		'_luaL_addlstring', \
		'_luaL_addstring', \
		'_luaL_addvalue', \
		'_luaL_pushresult', \
		'_luaL_pushresultsize', \
		'_luaL_buffinitsize', \
		'_luaL_error', \
		'_lua_newstate', \
		'_lua_close', \
		'_lua_newthread', \
		'_lua_resetthread', \
		'_lua_atpanic', \
		'_lua_version', \
		'_lua_absindex', \
		'_lua_gettop', \
		'_lua_settop', \
		'_lua_pushvalue', \
		'_lua_rotate', \
		'_lua_copy', \
		'_lua_checkstack', \
		'_lua_xmove', \
		'_lua_isnumber', \
		'_lua_isstring', \
		'_lua_iscfunction', \
		'_lua_isinteger', \
		'_lua_isuserdata', \
		'_lua_type', \
		'_lua_typename', \
		'_lua_tonumberx', \
		'_lua_tointegerx', \
		'_lua_toboolean', \
		'_lua_tolstring', \
		'_lua_rawlen', \
		'_lua_tocfunction', \
		'_lua_touserdata', \
		'_lua_tothread', \
		'_lua_topointer', \
		'_lua_arith', \
		'_lua_rawequal', \
		'_lua_compare', \
		'_lua_pushnil', \
		'_lua_pushnumber', \
		'_lua_pushinteger', \
		'_lua_pushlstring', \
		'_lua_pushstring', \
		'_lua_pushcclosure', \
		'_lua_pushboolean', \
		'_lua_pushlightuserdata', \
		'_lua_pushthread', \
		'_lua_getglobal', \
		'_lua_gettable', \
		'_lua_getfield', \
		'_lua_geti', \
		'_lua_rawget', \
		'_lua_rawgeti', \
		'_lua_rawgetp', \
		'_lua_createtable', \
		'_lua_newuserdatauv', \
		'_lua_getmetatable', \
		'_lua_getiuservalue', \
		'_lua_setglobal', \
		'_lua_settable', \
		'_lua_setfield', \
		'_lua_seti', \
		'_lua_rawset', \
		'_lua_rawseti', \
		'_lua_rawsetp', \
		'_lua_setmetatable', \
		'_lua_setiuservalue', \
		'_lua_callk', \
		'_lua_pcallk', \
		'_lua_load', \
		'_lua_dump', \
		'_lua_yieldk', \
		'_lua_resume', \
		'_lua_status', \
		'_lua_isyieldable', \
		'_lua_setwarnf', \
		'_lua_warning', \
		'_lua_error', \
		'_lua_next', \
		'_lua_concat', \
		'_lua_len', \
		'_lua_stringtonumber', \
		'_lua_getallocf', \
		'_lua_setallocf', \
		'_lua_toclose', \
		'_lua_closeslot', \
		'_lua_getstack', \
		'_lua_getinfo', \
		'_lua_getlocal', \
		'_lua_setlocal', \
		'_lua_getupvalue', \
		'_lua_setupvalue', \
		'_lua_upvalueid', \
		'_lua_upvaluejoin', \
		'_lua_sethook', \
		'_lua_gethook', \
		'_lua_gethookmask', \
		'_lua_gethookcount', \
		'_lua_setcstacklimit', \
		'_luaopen_base', \
		'_luaopen_coroutine', \
		'_luaopen_table', \
		'_luaopen_io', \
		'_luaopen_os', \
		'_luaopen_string', \
		'_luaopen_utf8', \
		'_luaopen_math', \
		'_luaopen_debug', \
		'_luaopen_package', \
		'_luaL_openlibs', \
		'_luaopen_ffi' \
	    ]"


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

# looks like LUAFFIFB still uses JIT for the calling
# how to get around it?
# use libffi for the calling.
# and luckily, in the last year, libffi has added emscripten-wasm support itself.
LIBFFI_SRCS = $(patsubst %, libffi/src/wasm32/%, \
	ffi.c \
)
LIBFFI_OBJS = $(patsubst %.c, %$(O), $(LIBFFI_SRCS))

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
DIST_SRCS= $(LUA_SRCS) \
	$(LIBFFI_SRCS) \
	$(LUAFFIFB_SRCS)
	# $(GNUPLOT_SRCS)
DIST_OBJS= $(patsubst %.c, %$(O), $(DIST_SRCS))

# compile rule for all:
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final
$(DIST): $(DIST_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^
	# now comment out the module declaration because it uses 'var' which will screw up even if I wrap it all in a function with a `Module` arg
	#sed 's/^var Module/\/\/var Module/' $(DIST) > temp && mv temp $(DIST)
	# now assign HEAP ... which it does already when I don't use MAIN_MODULE/SIDE_MODULE, so why did it stop when I started using MAIN_MODULE/SIDE_MODULE ?
	#sed 's/HEAP\([0-9a-zA-Z]*\) = /HEAP\1 = Module.HEAP\1 = /' $(DIST) > temp && mv temp $(DIST)
	# seems FreeBSD sed is different from Linux sed
	# now wrap it all in a module, because emscripten thinks using MAIN_MODULE/SIDE_MODULE prevents it from usinng modules / ES6 somehow (??? wtf)
	#echo 'const defaultModule = (Module = {}) => new Promise((initResolve, initReject) => {' | cat - $(DIST) > temp && mv temp $(DIST)
	#echo 'addOnPostRun(() => { initResolve(Module); }); }); export default defaultModule;' >> $(DIST)
	# TODO ALSO comment out var Module = line OR ELSE IT BREAKS because JAVASCRIPT IS TRASH
	# ALSO make sure in updateMemoryViews() to assign HEAP* to Module.HEAP* because EMSCRIPTEN IS TRASH TOO (it did this before, but stopped doing it when i switched to MAIN_MODULE/SIDE_MODULE, which was necessary to access dlopen/dlsym from js)

.PHONY: distclean
distclean:
	-rm $(DIST)
	-rm $(DIST_WASM)

INSTALL_DIR=../../thenumbernine.github.io/js/
.PHONY: install
install: $(DIST)
	cp $(DIST) $(INSTALL_DIR)
	cp $(DIST_WASM) $(INSTALL_DIR)
