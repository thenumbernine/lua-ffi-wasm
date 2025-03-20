# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy:

CFLAGS= -Wall -Wextra -DLUA_COMPAT_5_3 -I lua/
#CFLAGS+=  -std=gnu99
LDFLAGS=

############ emcc final:
CC=emcc
DIST=lua-5.4.7-with-ffi.js
DIST_WASM=lua-5.4.7-with-ffi.wasm
CFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#CFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
##	-target=wasm64-unknown-emscripten
#LDFLAGS+=- -no-debug -target=wasm64-unknown-emscripten -panic=trap -scheduler=none
#LDFLAGS+= --profiling-funcs
LDFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#LDFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
LDFLAGS+= -s EXPORT_ALL=1 # https://stackoverflow.com/a/33206957 ....  THIS IS NOT NEEDED TO EXPORT ALL TO WASM, BUT IT IS NEEDED TO EXPORT ALL TO JS !!!!! EMSCRIPTEN!!!!!
#LDFLAGS+= -s LINKABLE=1 -sEXPORT_ALL=1 # https://stackoverflow.com/a/33208675
LDFLAGS+= -s LINKABLE=1 # I need this to export **ANYTHING** but if I enable it then I can't also see malloc .. WHAT KIND OF STUPID IS AT PLAY HERE?! JUST WRITE _malloc TO Module LIKE YOU DO EVERYTHING ELSE!!!  OH WAIT, THE WARNING WAS LYING! DESPITE THE WARNING IT IN FACT DOES WRITE OUT _malloc, BUT WONT WITHOUT THE DEPRECATED VAR!
#LDFLAGS+= -s IGNORE_MISSING_MAIN=1 # ... isn't ignoring missing main ...
LDFLAGS+= --no-entry
#LDFLAGS+= -s STANDALONE_WASM	# https://stackoverflow.com/a/70230725
#LDFLAGS+= -sFULL_ES3	# maybe I can use wasm webgl<->gles3 instead of emu-lua ... and maybe it'll give me access to a getProcAddr function since dlopen/dlsym just returns 0 for everything ...
						# and NOPE.  adding "_glEnable" to EXPORTED_FUNCTIONS just spits out some retarded js code: var _glEnable=x0=>GLctx.enable(x0);Module["_glEnable"]=_glEnable
						# I was really hoping from some wasm-compiled webgl<->gles3 bindings ... maybe I can only get those if i turn off the JS layer .. and then I'd lose the FS emulation layer ...
						# where to get a virtual filesystem and ditch emscripten's ...
# fun story
# DEFAULT_TO_CXX=1 by default, which converts all the C symbols to C++ symbols and then mangles them into absolute worthlessness ... SO
# if you ever compile ***ANY C CODE*** in emscripten, your symbols ***BECOME TRASH*** without doing this ***AND*** adding `__attribute__((visibility("default")))` to all of them.
LDFLAGS+= -s DEFAULT_TO_CXX=0
# now how do I get access to the filesystem module ...
LDFLAGS+= -s FILESYSTEM=1
LDFLAGS+= -s FORCE_FILESYSTEM=1
LDFLAGS+= -s MODULARIZE=1 	# warning: MODULARIZE is only valid when generating JavaScript
#LDFLAGS+= -s EXPORT_ES6=1 # warning: EXPORT_ES6 is only valid when generating JavaScript . ... with js and wasm=1 I'm not seeing FS ...
#LDFLAGS+= -s WASM=0		# nope or it's pure javascript ...
LDFLAGS+= -s WASM=1 		# so I guess I have to output to javascript to use the filesystem ... ?
LDFLAGS+= -s ENVIRONMENT=web		# https://gioarc.me/posts/games/wasm-ii.html
LDFLAGS+= -s ALLOW_TABLE_GROWTH=1	# without it no dynamic stuff I guess?
LDFLAGS+= -s ALLOW_MEMORY_GROWTH=1	# otherwise my apps die after a few seconds
#LDFLAGS+= -s MEMORY64=1				# otherwise I'm getting the weird case that void*'s are 4bytes but structs-of-void*'s align to 8 bytes ...
LDFLAGS+= -s 'EXPORT_NAME="lua"'
LDFLAGS+= -s 'EXPORTED_FUNCTIONS=["_malloc", "_free", "_dlsym", "_dlopen"]'	# https://github.com/emscripten-core/emscripten/issues/6882#issuecomment-406745898
LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS", "ccall", "cwrap", "stringToNewUTF8", "addFunction"]'  # https://stackoverflow.com/a/64021522
#LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS", "cwrap", "allocate", "intArrayFromString"]'  # https://stackoverflow.com/a/64021522 https://github.com/emscripten-core/emscripten/issues/6061#issuecomment-357150650 and https://stackoverflow.com/a/46855162
# ... and absolutely none of these show up in the exports ...


############ clang, since emcc is wedging in tons of c++ crap, mangling symbol names, etc
#	CC=clang --target=wasm64 -Wl,--export-all -Wl,--no-entry
#	DIST=lua-5.4.7-with-ffi.wasm
# ... needs libc, or idk where wasm-libc is
#	#CFLAGS+=  --no-standard-libraries


############ local arch testing:
#	cc=clang
#	DIST=lua.out	# because 'lua' is a submodule - name in the dir is already used
#	CFLAGS+= -O2 -fPIC



.PHONY: all clean
all: $(DIST)

clean:
	-rm *.o $(DIST)

# Lua 5.4.7

lapi.o: lua/lapi.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcode.o: lua/lcode.c
	$(CC) $(CFLAGS) -c -o $@ $^

lctype.o: lua/lctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldebug.o: lua/ldebug.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldo.o: lua/ldo.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldump.o: lua/ldump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lfunc.o: lua/lfunc.c
	$(CC) $(CFLAGS) -c -o $@ $^

lgc.o: lua/lgc.c
	$(CC) $(CFLAGS) -c -o $@ $^

llex.o: lua/llex.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmem.o: lua/lmem.c
	$(CC) $(CFLAGS) -c -o $@ $^

lobject.o: lua/lobject.c
	$(CC) $(CFLAGS) -c -o $@ $^

lopcodes.o: lua/lopcodes.c
	$(CC) $(CFLAGS) -c -o $@ $^

lparser.o: lua/lparser.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstate.o: lua/lstate.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstring.o: lua/lstring.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltable.o: lua/ltable.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltm.o: lua/ltm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lundump.o: lua/lundump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lvm.o: lua/lvm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lzio.o: lua/lzio.c
	$(CC) $(CFLAGS) -c -o $@ $^

lauxlib.o: lua/lauxlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lbaselib.o: lua/lbaselib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcorolib.o: lua/lcorolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldblib.o: lua/ldblib.c
	$(CC) $(CFLAGS) -c -o $@ $^

liolib.o: lua/liolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmathlib.o: lua/lmathlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loadlib.o: lua/loadlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loslib.o: lua/loslib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstrlib.o: lua/lstrlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltablib.o: lua/ltablib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lutf8lib.o: lua/lutf8lib.c
	$(CC) $(CFLAGS) -c -o $@ $^

linit.o: lua/linit.c
	$(CC) $(CFLAGS) -c -o $@ $^

#lua.o: lua/lua.c
#	$(CC) $(CFLAGS) -c -o $@ $^

# LuaFFI-FB

luaffifb_call.o: luaffifb/call.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ctype.o: luaffifb/ctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ffi.o: luaffifb/ffi.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_parser.o: luaffifb/parser.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final

$(DIST): \
	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o \
	luaffifb_call.o luaffifb_ctype.o luaffifb_ffi.o luaffifb_parser.o
	#lua.o
	$(CC) $(LDFLAGS) -o $@ $^
	# last step
	# fix the es6 exporter
	# and fix the .js' loading .wasm location
	./fixjs.lua injs=$(DIST) inwasm=$(DIST_WASM) outjs=$(DIST) outwasm=/js/$(DIST_WASM)

