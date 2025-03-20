# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy:

CFLAGS= -Wall -Wextra -DLUA_COMPAT_5_3 -I lua/
#CFLAGS+=  -std=gnu99
LDFLAGS=




############ clang, since emcc is wedging in tons of c++ crap, mangling symbol names, etc
# osx notice: use brew clang since builtin clang is a few versions behind and doesn't yet have wasm target: 
#   `export PATH=/usr/local/opt/llvm/bin:$PATH`
CC=clang
O=.o	# .bc ?
DIST=lua-5.4.7-with-ffi.wasm	# .bca ?

# wasi-libc I built myself .. still missingruntimes,
#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot 
#LDFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot 
# so just using `brew install wasi-libc wasi-runtimes` 
# and now complex doesn't work, so what went wrong
CFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot
LDFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot

#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/build # why ask me for an install dir if you're just going to install to ./sysroot ?
#CFLAGS+= --target=wasm32-wasi # works 
#CFLAGS+= --target=wasm64 # 'string.h' file not found
#CFLAGS+= --target=wasm64-wasi # 'string.h' file not found
#CFLAGS+= --target=wasm64-unknown-wasi # 'string.h' file not found
CFLAGS+= --target=wasm32-unknown-wasi # works
LDFLAGS+= --target=wasm32-unknown-wasi 
CFLAGS+= -O2

# for signals:
CFLAGS+= -D_WASI_EMULATED_SIGNAL
LDFLAGS+= -lwasi-emulated-signal

# for longjmp ... 
CFLAGS+= -mllvm -wasm-enable-sjlj
# .. alternatively just compile ldo as C++ ( everything as C++?) and Lua will use throw instead:
#CFLAGS+= -x c++ #-std=c++11
# but then I get link errors of `undefined symbol: __cxa_allocate_exception` so back to C...

# tmpfile() is deprecated & L_tmpnam are missing on wasi-libc, so I made this flag to tell Lua build to get around that, and use the LUA_USE_POSIX tmpfile option:
CFLAGS+= -DLUA_TMPFILE_MISSING

# for clock() to work:
CFLAGS+= -D_WASI_EMULATED_PROCESS_CLOCKS 
LDFLAGS+= -lwasi-emulated-process-clocks

# mmap:
CFLAGS+= -D_WASI_EMULATED_MMAN 
LDFLAGS+= -lwasi-emulated-mman

# for luaffifb to tell the arch
CFLAGS+= -D__WASM__

LDFLAGS+= -ldl	# dlopen/dlsym

# "Despite claiming to be ISO C, iOS does not implement 'system'."
#CFLAGS+= -DLUA_USE_IOS	
# but if you enable this it causes lots more compile/link errors to pop up ... so ...
CFLAGS+= -DLUA_MISSING_SYSTEM

# where'd my symbols go?
#LDFLAGS+= -fvisibility default
#CFLAGS+= -fPIC "-DLUA_API=extern"
#LDFLAGS+= -shared # wasm-ld: warning: creating shared libraries, with -shared, is not yet stable
LDFLAGS+= -Wl,--export-all




############ emcc final:
#	CC=emcc
#	O=.o	# .bc?
#	DIST=lua-5.4.7-with-ffi.js
#	DIST_WASM=lua-5.4.7-with-ffi.wasm
#	CFLAGS+= -g3		# keep all debug info
#	LDFLAGS+= -g3		# keep all debug info
#	CFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#	#CFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
#	##	-target=wasm64-unknown-emscripten
#	#LDFLAGS+=- -no-debug -target=wasm64-unknown-emscripten -panic=trap -scheduler=none
#	#LDFLAGS+= --profiling-funcs
#	LDFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#	#LDFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
#	LDFLAGS+= -s EXPORT_ALL=1 # https://stackoverflow.com/a/33206957 ....  THIS IS NOT NEEDED TO EXPORT ALL TO WASM, BUT IT IS NEEDED TO EXPORT ALL TO JS !!!!! EMSCRIPTEN!!!!!
#	#LDFLAGS+= -s LINKABLE=1 -sEXPORT_ALL=1 # https://stackoverflow.com/a/33208675
#	LDFLAGS+= -s LINKABLE=1 # I need this to export **ANYTHING** but if I enable it then I can't also see malloc .. WHAT KIND OF STUPID IS AT PLAY HERE?! JUST WRITE _malloc TO Module LIKE YOU DO EVERYTHING ELSE!!!  OH WAIT, THE WARNING WAS LYING! DESPITE THE WARNING IT IN FACT DOES WRITE OUT _malloc, BUT WONT WITHOUT THE DEPRECATED VAR!
#	#LDFLAGS+= -s IGNORE_MISSING_MAIN=1 # ... isn't ignoring missing main ...
#	LDFLAGS+= --no-entry
#	#LDFLAGS+= -s STANDALONE_WASM	# https://stackoverflow.com/a/70230725
#	#LDFLAGS+= -sFULL_ES3	# maybe I can use wasm webgl<->gles3 instead of emu-lua ... and maybe it'll give me access to a getProcAddr function since dlopen/dlsym just returns 0 for everything ...
#							# and NOPE.  adding "_glEnable" to EXPORTED_FUNCTIONS just spits out some retarded js code: var _glEnable=x0=>GLctx.enable(x0);Module["_glEnable"]=_glEnable
#							# I was really hoping from some wasm-compiled webgl<->gles3 bindings ... maybe I can only get those if i turn off the JS layer .. and then I'd lose the FS emulation layer ...
#							# where to get a virtual filesystem and ditch emscripten's ...
#	# fun story
#	# DEFAULT_TO_CXX=1 by default, which converts all the C symbols to C++ symbols and then mangles them into absolute worthlessness ... SO
#	# if you ever compile ***ANY C CODE*** in emscripten, your symbols ***BECOME TRASH*** without doing this ***AND*** adding `__attribute__((visibility("default")))` to all of them.
#	LDFLAGS+= -s DEFAULT_TO_CXX=0
#	# now how do I get access to the filesystem module ...
#	LDFLAGS+= -s FILESYSTEM=1
#	LDFLAGS+= -s FORCE_FILESYSTEM=1
#	LDFLAGS+= -s MODULARIZE=1 	# warning: MODULARIZE is only valid when generating JavaScript
#	#LDFLAGS+= -s EXPORT_ES6=1 # warning: EXPORT_ES6 is only valid when generating JavaScript . ... with js and wasm=1 I'm not seeing FS ...
#	#LDFLAGS+= -s WASM=0		# nope or it's pure javascript ...
#	LDFLAGS+= -s WASM=1 		# so I guess I have to output to javascript to use the filesystem ... ?
#	LDFLAGS+= -s ENVIRONMENT=web		# https://gioarc.me/posts/games/wasm-ii.html
#	LDFLAGS+= -s ALLOW_TABLE_GROWTH=1	# without it no dynamic stuff I guess?
#	LDFLAGS+= -s ALLOW_MEMORY_GROWTH=1	# otherwise my apps die after a few seconds
#	#LDFLAGS+= -s MEMORY64=1				# otherwise I'm getting the weird case that void*'s are 4bytes but structs-of-void*'s align to 8 bytes ...
#	LDFLAGS+= -s 'EXPORT_NAME="lua"'
#	LDFLAGS+= -s 'EXPORTED_FUNCTIONS=["_malloc", "_free", "_dlsym", "_dlopen"]'	# https://github.com/emscripten-core/emscripten/issues/6882#issuecomment-406745898
#	LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS", "ccall", "cwrap", "stringToNewUTF8", "addFunction"]'  # https://stackoverflow.com/a/64021522
#	#LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS", "cwrap", "allocate", "intArrayFromString"]'  # https://stackoverflow.com/a/64021522 https://github.com/emscripten-core/emscripten/issues/6061#issuecomment-357150650 and https://stackoverflow.com/a/46855162
#	# ... and absolutely none of these show up in the exports ...




############ native arch testing:
#	cc=clang
#	O=.o
#	DIST=lua.out	# because 'lua' is a submodule - name in the dir is already used
#	CFLAGS+= -O2 -fPIC



.PHONY: all clean
all: $(DIST)

clean:
	-rm *$(O) $(DIST)

# Lua 5.4.7

lapi$(O): lua/lapi.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcode$(O): lua/lcode.c
	$(CC) $(CFLAGS) -c -o $@ $^

lctype$(O): lua/lctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldebug$(O): lua/ldebug.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldo$(O): lua/ldo.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldump$(O): lua/ldump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lfunc$(O): lua/lfunc.c
	$(CC) $(CFLAGS) -c -o $@ $^

lgc$(O): lua/lgc.c
	$(CC) $(CFLAGS) -c -o $@ $^

llex$(O): lua/llex.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmem$(O): lua/lmem.c
	$(CC) $(CFLAGS) -c -o $@ $^

lobject$(O): lua/lobject.c
	$(CC) $(CFLAGS) -c -o $@ $^

lopcodes$(O): lua/lopcodes.c
	$(CC) $(CFLAGS) -c -o $@ $^

lparser$(O): lua/lparser.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstate$(O): lua/lstate.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstring$(O): lua/lstring.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltable$(O): lua/ltable.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltm$(O): lua/ltm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lundump$(O): lua/lundump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lvm$(O): lua/lvm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lzio$(O): lua/lzio.c
	$(CC) $(CFLAGS) -c -o $@ $^

lauxlib$(O): lua/lauxlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lbaselib$(O): lua/lbaselib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcorolib$(O): lua/lcorolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldblib$(O): lua/ldblib.c
	$(CC) $(CFLAGS) -c -o $@ $^

liolib$(O): lua/liolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmathlib$(O): lua/lmathlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loadlib$(O): lua/loadlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loslib$(O): lua/loslib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstrlib$(O): lua/lstrlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltablib$(O): lua/ltablib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lutf8lib$(O): lua/lutf8lib.c
	$(CC) $(CFLAGS) -c -o $@ $^

linit$(O): lua/linit.c
	$(CC) $(CFLAGS) -c -o $@ $^

#lua$(O): lua/lua.c
#	$(CC) $(CFLAGS) -c -o $@ $^

# LuaFFI-FB

luaffifb_call$(O): luaffifb/call.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ctype$(O): luaffifb/ctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ffi$(O): luaffifb/ffi.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_parser$(O): luaffifb/parser.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final

$(DIST): \
	lapi$(O) lcode$(O) lctype$(O) ldebug$(O) ldo$(O) ldump$(O) lfunc$(O) lgc$(O) llex$(O) lmem$(O) lobject$(O) lopcodes$(O) lparser$(O) lstate$(O) lstring$(O) ltable$(O) ltm$(O) lundump$(O) lvm$(O) lzio$(O) lauxlib$(O) lbaselib$(O) lcorolib$(O) ldblib$(O) liolib$(O) lmathlib$(O) loadlib$(O) loslib$(O) lstrlib$(O) ltablib$(O) lutf8lib$(O) linit$(O) \
	luaffifb_call$(O) luaffifb_ctype$(O) luaffifb_ffi$(O) luaffifb_parser$(O)
	$(CC) $(LDFLAGS) -o $@ $^
